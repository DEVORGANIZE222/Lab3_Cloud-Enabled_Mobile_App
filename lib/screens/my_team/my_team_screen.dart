import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/team.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/format.dart';
import '../../viewmodels/my_team_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/states.dart';
import '../../widgets/status.dart';
import '../shared/profile_action.dart';
import '../shared/team_status.dart';

/// SCR_05 My Team (Figma `SCR_05: My Group Hub` and `SCR_05 (Leader View - Ready to Lock)`).
class MyTeamScreen extends StatelessWidget {
  const MyTeamScreen({super.key});

  Future<void> _leave(BuildContext context, Team team) async {
    final vm = context.read<MyTeamViewModel>();
    final ok = await showAppDialog(
      context,
      semanticId: 'dialog_leave',
      destructive: true,
      title: 'Leave ${team.name}?',
      message:
          'Your slot opens for other students and your vote is removed. '
          'You can join again only if a slot is still open.',
      confirmLabel: 'Leave Team',
    );
    if (!ok || !context.mounted) return;
    final failure = await vm.leave(team);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure == null ? 'You left ${team.name}' : '${failure.title}. ${failure.cause}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyTeamViewModel>();
    return BlockingOverlay(
      visible: vm.leaving,
      message: 'Leaving team…',
      child: Scaffold(
        appBar: const AppTopBar(title: 'My Team', showBack: false, actions: [ProfileAction()]),
        body: RefreshIndicator(
          onRefresh: vm.load,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              ViewStateView<Team>(
                state: vm.state,
                onRetry: vm.load,
                empty: EmptyState(
                  icon: Icons.group_off_outlined,
                  title: "You're not in a team yet",
                  message: 'Browse teams with open slots and join one before the registration deadline.',
                  actionLabel: 'Browse Teams',
                  onAction: () => context.go('/browse'),
                ),
                builder: (context, team) => _Body(team: team, onLeave: () => _leave(context, team)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.team, required this.onLeave});

  final Team team;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<MyTeamViewModel>();
    final phase = vm.phaseOf(team);
    final p = teamPhase(team);
    final leader = vm.isLeader(team);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          semanticId: 'card_my_team_header',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusBadge(label: team.code, tone: Tone.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: StatusBadge(label: p.label, tone: p.tone, icon: p.icon),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(header: true, child: Text(team.name, style: context.text.titleLarge)),
              const SizedBox(height: AppSpacing.xs),
              Text(team.topic, style: context.text.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              _Steps(phase: phase),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PhaseBanner(team: team, phase: phase, isLeader: leader, hasVoted: vm.hasVoted(team)),
        if (phase != TeamPhase.locked) ...[
          const SizedBox(height: AppSpacing.lg),
          if (phase == TeamPhase.electLeader || !vm.hasVoted(team))
            AppButton(
              semanticId: 'btn_vote_leader',
              label: vm.hasVoted(team) ? 'Change Vote' : 'Vote for Leader',
              icon: Icons.how_to_vote,
              variant: phase == TeamPhase.electLeader ? AppButtonVariant.primary : AppButtonVariant.secondary,
              onPressed: () => context.push('/team/vote'),
            ),
          if (phase != TeamPhase.electLeader) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              semanticId: 'btn_review_lock',
              label: 'Review & Lock',
              icon: Icons.fact_check,
              variant: leader ? AppButtonVariant.primary : AppButtonVariant.secondary,
              onPressed: () => context.push('/team/lock'),
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: 'Members', trailing: '${team.memberCount} of ${team.capacity}'),
        const SizedBox(height: AppSpacing.md),
        for (final m in team.members) ...[
          MemberTile(
            member: m,
            badges: [
              if (m.studentId == vm.myId) const StatusBadge(label: 'You', tone: Tone.info, icon: Icons.person),
              if (m.studentId == team.leaderId)
                const StatusBadge(label: 'Leader', tone: Tone.primary, icon: Icons.star),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        for (var i = 0; i < team.openSlots; i++) ...[
          OpenSlotTile(
            slot: team.memberCount + i + 1,
            lookingFor: i < team.openRoles.length ? team.openRoles[i] : 'Any role',
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (phase != TeamPhase.locked) ...[
          const SizedBox(height: AppSpacing.md),
          AppButton(
            semanticId: 'btn_leave_team',
            label: 'Leave Team',
            variant: AppButtonVariant.text,
            onPressed: onLeave,
          ),
        ],
      ],
    );
  }
}

/// Three-step progress (Form → Elect → Lock) so the next step is always visible.
class _Steps extends StatelessWidget {
  const _Steps({required this.phase});

  final TeamPhase phase;

  @override
  Widget build(BuildContext context) {
    final done = switch (phase) {
      TeamPhase.electLeader => 0,
      TeamPhase.inFormation => 1,
      TeamPhase.readyToLock => 2,
      TeamPhase.locked => 3,
    };
    const labels = ['Elect leader', '4+ members', 'Lock roster'];
    return Semantics(
      label: 'Step ${done.clamp(0, 2) + 1} of 3: ${labels[done.clamp(0, 2)]}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Column(
                children: [
                  Icon(
                    i < done ? Icons.check_circle : (i == done ? Icons.radio_button_checked : Icons.circle_outlined),
                    color: i < done
                        ? context.appColors.success
                        : (i == done ? context.colors.primary : context.colors.outline),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(labels[i], style: context.text.bodySmall, textAlign: TextAlign.center),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PhaseBanner extends StatelessWidget {
  const _PhaseBanner({required this.team, required this.phase, required this.isLeader, required this.hasVoted});

  final Team team;
  final TeamPhase phase;
  final bool isLeader;
  final bool hasVoted;

  @override
  Widget build(BuildContext context) {
    final voted = team.votes.length;
    return switch (phase) {
      TeamPhase.electLeader => InfoBanner(
        semanticId: 'banner_phase',
        tone: Tone.warning,
        icon: Icons.how_to_vote,
        title: hasVoted ? 'Waiting for more votes' : 'Vote for your team leader',
        message:
            '$voted of ${team.memberCount} members have voted. '
            'A leader needs ${team.votesNeeded} votes.',
      ),
      TeamPhase.inFormation => InfoBanner(
        semanticId: 'banner_phase',
        tone: Tone.warning,
        icon: Icons.group_add,
        title: 'Needs ${Fmt.count(TeamRules.minMembers - team.memberCount, 'more member')} to lock',
        message: isLeader
            ? 'Invite students from the Waiting Pool on Review & Lock.'
            : '${team.leader!.fullName}, your leader, can invite students from the Waiting Pool.',
      ),
      TeamPhase.readyToLock => InfoBanner(
        semanticId: 'banner_phase',
        tone: Tone.success,
        title: 'Ready to lock',
        message: isLeader
            ? 'Review the roster and lock it to send it to the Academic Office.'
            : 'Waiting for ${team.leader!.fullName} to lock the roster.',
      ),
      TeamPhase.locked => InfoBanner(
        semanticId: 'banner_phase',
        tone: Tone.success,
        icon: Icons.lock,
        title: 'Roster locked · ${team.lockCode}',
        message:
            'Sent to the Academic Office'
            '${team.lockedAt == null ? '' : ' on ${Fmt.dateTime(team.lockedAt!)}'}. '
            'Contact them to change your team.',
      ),
    };
  }
}
