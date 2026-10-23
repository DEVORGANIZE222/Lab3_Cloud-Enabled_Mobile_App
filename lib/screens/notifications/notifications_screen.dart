import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/app_notification.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/format.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/states.dart';
import '../../widgets/status.dart';
import '../shared/feedback.dart';
import '../shared/profile_action.dart';
import '../shared/team_status.dart';

/// SCR_09 Alerts (Figma `SCR_09: Notifications & Invites`).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _filterLabels = {AlertFilter.all: 'All', AlertFilter.invites: 'Invites', AlertFilter.system: 'Updates'};

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();
    return Scaffold(
      appBar: AppTopBar(
        title: 'Alerts',
        showBack: false,
        actions: [
          if (vm.unread > 0)
            Semantics(
              identifier: 'btn_mark_all_read',
              child: TextButton(
                onPressed: () async {
                  final failure = await vm.markAllRead();
                  if (failure != null && context.mounted) showFailure(context, failure);
                },
                child: const Text('Mark All Read'),
              ),
            ),
          const ProfileAction(),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          Semantics(
            identifier: 'alert_filters',
            container: true,
            child: SegmentedButton<AlertFilter>(
              showSelectedIcon: false,
              segments: [
                for (final f in AlertFilter.values)
                  ButtonSegment(value: f, label: Text('${_filterLabels[f]} (${vm.count(f)})')),
              ],
              selected: {vm.filter},
              onSelectionChanged: (s) => vm.setFilter(s.first),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ViewStateView<List<AppNotification>>(
            state: vm.state,
            onRetry: vm.start,
            empty: EmptyState(
              icon: Icons.notifications_none,
              title: "You're all caught up",
              message: vm.filter == AlertFilter.invites
                  ? 'Team invites will show up here.'
                  : 'Votes, invites and deadline reminders will show up here.',
            ),
            builder: (context, items) => Column(
              children: [
                for (final n in items) ...[_NotificationCard(item: n), const SizedBox(height: AppSpacing.md)],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final AppNotification item;

  Future<void> _decline(BuildContext context) async {
    final vm = context.read<NotificationsViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final failure = await vm.decline(item);
    if (!context.mounted) return;
    if (failure != null) return showFailure(context, failure);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Invite declined'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final undoFailure = await vm.restore(item);
            if (undoFailure != null && context.mounted) showFailure(context, undoFailure);
          },
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    final vm = context.read<NotificationsViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final failure = await vm.accept(item);
    if (!context.mounted) return;
    if (failure != null) return showFailure(context, failure);
    messenger.showSnackBar(const SnackBar(content: Text('Invite accepted. Welcome to your new team')));
    context.go('/team');
  }

  void _open(BuildContext context) {
    context.read<NotificationsViewModel>().open(item);
    if (item.teamId == null) return;
    switch (item.kind) {
      case NotificationKind.vote:
        context.push('/team/vote');
      case NotificationKind.application:
        context.push('/team/lock');
      case NotificationKind.invite:
        context.push('/browse/team/${item.teamId}');
      case NotificationKind.system:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      semanticId: 'alert_${item.id}',
      semanticLabel: '${item.read ? '' : 'Unread. '}${item.title}',
      color: item.read ? null : c.primaryContainer.withValues(alpha: 0.35),
      onTap: () => _open(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: c.primaryContainer,
                child: Icon(notificationIcon(item.kind), color: c.onPrimaryContainer),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: context.text.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(item.body, style: context.text.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(Fmt.ago(item.createdAt, DateTime.now()), style: context.text.bodySmall),
                    // Aligned with the text column, not the card edge.
                    if (!item.isInvite && item.actionLabel != null && item.teamId != null)
                      AppButton(
                        label: item.actionLabel!,
                        variant: AppButtonVariant.text,
                        expand: false,
                        onPressed: () => _open(context),
                      ),
                  ],
                ),
              ),
              if (!item.read)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: StatusBadge(label: 'New', tone: Tone.primary),
                ),
            ],
          ),
          if (item.isInvite) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    semanticId: 'btn_decline_${item.id}',
                    label: 'Decline',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => _decline(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    semanticId: 'btn_accept_${item.id}',
                    label: 'Accept',
                    onPressed: () => _accept(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
