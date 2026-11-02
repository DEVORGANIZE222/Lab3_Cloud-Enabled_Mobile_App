import 'package:flutter/material.dart';

import '../../models/app_notification.dart';
import '../../models/team.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status.dart';

/// One status vocabulary for a team everywhere it appears (UI consistency:
/// "each concept has one name"; status colours only for status). Same order
/// as `MyTeamViewModel.phaseOf`.
({String label, Tone tone, IconData icon}) teamPhase(Team t) {
  if (t.locked) return (label: 'Locked', tone: Tone.success, icon: Icons.lock);
  if (!t.hasLeader) return (label: 'Leader not elected', tone: Tone.warning, icon: Icons.how_to_vote);
  if (!t.meetsSizeRule) {
    return (label: 'Needs members · ${t.memberCount}/${t.capacity}', tone: Tone.warning, icon: Icons.group_add);
  }
  return (label: 'Ready to lock', tone: Tone.success, icon: Icons.check_circle);
}

String teamPhaseLabel(Team t) => teamPhase(t).label;

IconData notificationIcon(NotificationKind k) => switch (k) {
  NotificationKind.invite => Icons.person_add_alt_1,
  NotificationKind.vote => Icons.how_to_vote,
  NotificationKind.system => Icons.campaign,
  NotificationKind.application => Icons.verified,
};

/// Team summary card used on Dashboard (Figma "Current team status").
class TeamStatusCard extends StatelessWidget {
  const TeamStatusCard({super.key, required this.team, this.onTap});

  final Team team;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = teamPhase(team);
    final needs = <String>[
      if (team.memberCount < TeamRules.minMembers) Fmt.count(TeamRules.minMembers - team.memberCount, 'more member'),
      if (!team.hasLeader) 'a leader',
    ];
    return AppCard(
      semanticId: 'card_team_status',
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CURRENT TEAM STATUS',
                  style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant, letterSpacing: 0.6),
                ),
              ),
              StatusBadge(label: p.label, tone: p.tone, icon: p.icon),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(team.name, style: context.text.titleLarge),
              StatusBadge(label: team.code),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(team.topic, style: context.text.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.groups, size: AppSize.iconSmall, color: context.colors.primary),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${team.memberCount}/${team.capacity} members formed ',
                        style: context.text.labelLarge?.copyWith(color: context.colors.primary),
                      ),
                      TextSpan(text: '(minimum ${TeamRules.minMembers} required)', style: context.text.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SlotRow(memberInitials: [for (final m in team.members) m.initials], capacity: team.capacity),
          if (needs.isNotEmpty && !team.locked) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: context.colors.surfaceContainerHigh, borderRadius: AppRadius.smAll),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 20, color: context.appColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Needs ${needs.join(' and ')} before locking.', style: context.text.bodyMedium),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Stat(value: '${team.memberCount}/${team.capacity}', label: 'Team size', ok: team.meetsSizeRule),
              const SizedBox(width: AppSpacing.sm),
              _Stat(value: team.hasLeader ? 'Elected' : 'Pending', label: 'Leader', ok: team.hasLeader),
              const SizedBox(width: AppSpacing.sm),
              const _Stat(value: 'Assigned', label: 'Supervisor', ok: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// Figma "Formation Health" tile: grey panel, coloured value, caption.
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.ok});

  final String value;
  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? context.colors.primary : context.appColors.warning;
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
          decoration: BoxDecoration(color: context.colors.surfaceContainerHigh, borderRadius: AppRadius.smAll),
          child: Column(
            children: [
              Text(value, style: context.text.titleMedium?.copyWith(color: color), maxLines: 1),
              const SizedBox(height: 2),
              Text(label, style: context.text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Roster row (Team Detail, My Team, Lock Review).
class MemberTile extends StatelessWidget {
  const MemberTile({super.key, required this.member, this.badges = const [], this.trailing});

  final TeamMember member;
  final List<Widget> badges;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      semanticId: 'member_${member.studentId}',
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          MemberAvatar(initials: member.initials),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  '${member.studentCode} · ${member.role}',
                  style: context.text.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(spacing: AppSpacing.xs, runSpacing: AppSpacing.xs, children: badges),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Dashed card for an open slot ("Looking for: …").
class OpenSlotTile extends StatelessWidget {
  const OpenSlotTile({super.key, required this.slot, required this.lookingFor});

  final int slot;
  final String lookingFor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: context.colors.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          const MemberAvatar(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Open slot $slot', style: context.text.titleSmall),
                Text('Looking for: $lookingFor', style: context.text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
