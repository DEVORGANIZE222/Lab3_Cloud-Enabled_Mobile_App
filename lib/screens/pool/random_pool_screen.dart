import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/registration.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/format.dart';
import '../../viewmodels/pool_status_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/states.dart';
import '../../widgets/status.dart';

/// SCR_08 Random Pool status (Figma `SCR_08: Random Pool Status`).
class RandomPoolScreen extends StatelessWidget {
  const RandomPoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PoolStatusViewModel>();
    return Scaffold(
      appBar: const AppTopBar(title: 'Matching Status'),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => vm.load(userRefresh: true),
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              ViewStateView<PoolStatus>(
                state: vm.state,
                onRetry: vm.load,
                builder: (context, p) => _Body(status: p, refreshing: vm.refreshing, onRefresh: vm.load),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.status, required this.refreshing, required this.onRefresh});

  final PoolStatus status;
  final bool refreshing;
  final Future<void> Function({bool userRefresh}) onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const InfoBanner(
          semanticId: 'banner_pool',
          tone: Tone.info,
          icon: Icons.hourglass_top,
          title: "You're in the Random Pool",
          message:
              'Registration closed before you joined a team. '
              'The system is matching you with students who need your role.',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          semanticId: 'card_pool_progress',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Queue ${status.queueId}', style: context.text.titleMedium)),
                  const StatusBadge(label: 'Matching', tone: Tone.warning, icon: Icons.sync),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppProgressBar(value: status.progress, label: '${status.stage} · ${Fmt.percent(status.progress)}'),
              const SizedBox(height: AppSpacing.lg),
              InfoRow(icon: Icons.event, label: 'Expected result', value: Fmt.dateTime(status.expectedResult)),
              InfoRow(icon: Icons.groups_outlined, label: 'Students in pool', value: '${status.studentsInPool}'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Your matching profile'),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preferred roles', style: context.text.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [for (final r in status.preferredRoles) StatusBadge(label: r, tone: Tone.primary)],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Skills', style: context.text.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [for (final s in status.skills) StatusBadge(label: s)],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          identifier: 'pool_last_checked',
          liveRegion: true,
          child: Text(
            'Last checked ${Fmt.ago(status.lastChecked, DateTime.now()).toLowerCase()}',
            style: context.text.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          semanticId: 'btn_refresh_pool',
          label: refreshing ? 'Checking…' : 'Check Again',
          icon: Icons.refresh,
          variant: AppButtonVariant.secondary,
          loading: refreshing,
          onPressed: () => onRefresh(userRefresh: true),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Questions about matching? Email ${status.contactEmail}.',
          style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
