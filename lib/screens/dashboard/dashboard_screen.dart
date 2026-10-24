import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/app_notification.dart';
import '../../models/view_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/format.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/states.dart';
import '../../widgets/status.dart';
import '../shared/profile_action.dart';
import '../shared/team_status.dart';

/// SCR_02 Dashboard (Figma `SCR_02: Dashboard / Home`).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    return Scaffold(
      appBar: const AppTopBar(title: 'Home', showBack: false, actions: [ProfileAction()]),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            ViewStateView<DashboardData>(
              state: vm.state,
              onRetry: vm.load,
              builder: (context, d) => _DashboardBody(data: d),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final team = data.team;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text('Hi, ${data.student.firstName}!', style: context.text.headlineMedium)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: Text('${data.student.studentCode} · ${data.student.major}', style: context.text.bodyMedium),
            ),
            StatusBadge(label: data.student.cohort, tone: Tone.primary, icon: Icons.school),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (data.registrationClosed)
          InfoBanner(
            semanticId: 'banner_registration_closed',
            tone: Tone.error,
            title: 'Registration is closed',
            message: team == null
                ? 'You were not in a team at the deadline, so the system placed you in the Random Pool.'
                : 'Changes to ${team.name} now go through the Academic Office.',
          )
        else
          AppCard(
            semanticId: 'card_deadline',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Registration deadline', style: context.text.labelMedium)),
                    if (data.urgent) const StatusBadge(label: 'Urgent', tone: Tone.warning, icon: Icons.schedule),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  Fmt.countdown(data.timeLeft),
                  style: context.text.headlineMedium?.copyWith(
                    color: data.urgent ? context.appColors.warning : context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Closes ${Fmt.dateTime(data.window.closesAt)}', style: context.text.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                AppProgressBar(
                  value: data.window.elapsed(data.now),
                  tone: Tone.warning,
                  label: '${data.window.semester} registration · ${Fmt.percent(data.window.elapsed(data.now))} elapsed',
                ),
              ],
            ),
          ),
        if (data.registrationClosed && data.showPoolEntry && team == null) ...[
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            semanticId: 'btn_view_matching_status',
            label: 'View Matching Status',
            icon: Icons.hourglass_top,
            onPressed: () => context.push('/home/pool'),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'My team'),
        const SizedBox(height: AppSpacing.md),
        if (team == null) _NoTeamCard(closed: data.registrationClosed) else TeamStatusCard(team: team),
        const SizedBox(height: AppSpacing.lg),
        if (!data.registrationClosed) ...[
          if (team == null)
            AppButton(
              semanticId: 'btn_browse_teams',
              label: 'Browse Available Teams',
              icon: Icons.search,
              onPressed: () => context.go('/browse'),
            )
          else ...[
            AppButton(
              semanticId: 'btn_manage_team',
              label: 'Manage ${team.name}',
              icon: Icons.groups,
              onPressed: () => context.go('/team'),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              semanticId: 'btn_browse_teams',
              label: 'Browse Teams',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.go('/browse'),
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.xl),
        const _RecentNotices(),
      ],
    );
  }
}

class _NoTeamCard extends StatelessWidget {
  const _NoTeamCard({required this.closed});

  final bool closed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      semanticId: 'card_no_team',
      child: Row(
        children: [
          Icon(Icons.group_off_outlined, color: context.colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You're not in a team yet", style: context.text.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  closed
                      ? 'The Random Pool will place you in a team. Check your matching status for updates.'
                      : 'Teams with open slots are waiting. Join one before the deadline.',
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentNotices extends StatelessWidget {
  const _RecentNotices();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationsViewModel>().state;
    final items = switch (state) {
      Data<List<AppNotification>>(:final value) => value.take(2).toList(),
      _ => const <AppNotification>[],
    };
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: SectionHeader(title: 'Recent notices')),
            AppButton(
              label: 'See All',
              variant: AppButtonVariant.text,
              expand: false,
              onPressed: () => context.go('/alerts'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final n in items) ...[
          AppCard(
            onTap: () => context.go('/alerts'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(notificationIcon(n.kind), color: context.colors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title, style: context.text.labelLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AppSpacing.xs),
                      Text(Fmt.ago(n.createdAt, DateTime.now()), style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
