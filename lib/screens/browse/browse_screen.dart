import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/team.dart';
import '../../models/view_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../viewmodels/browse_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/states.dart';
import '../../widgets/status.dart';
import '../shared/profile_action.dart';

/// SCR_03 Browse Teams (Figma `SCR_03: Browse Groups`, renamed per DV-01).
class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BrowseViewModel>();
    final state = vm.state;
    return Scaffold(
      appBar: const AppTopBar(title: 'Browse Teams', showBack: false, actions: [ProfileAction()]),
      body: RefreshIndicator(
        onRefresh: vm.search,
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            AppSearchField(
              controller: _search,
              onSubmitted: vm.search,
              onClear: () {
                _search.clear();
                vm.search('');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              identifier: 'browse_filters',
              container: true,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final f in TeamFilter.values)
                    AppChip(
                      label: f.label,
                      selected: vm.filters.contains(f),
                      onSelected: (on) => vm.toggleFilter(f, on),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (state is Data<List<Team>>) ...[
              Semantics(
                identifier: 'browse_result_count',
                liveRegion: true,
                child: Text(
                  '${state.value.length} ${state.value.length == 1 ? 'team' : 'teams'}'
                  '${vm.filters.contains(TeamFilter.openSlots) ? ' with open slots' : ''}',
                  style: context.text.labelMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            ViewStateView<List<Team>>(
              state: state,
              onRetry: vm.search,
              empty: EmptyState(
                icon: Icons.search_off,
                title: 'No teams match your search',
                message: vm.hasCriteria
                    ? 'Try a different keyword or clear the filters to see every team with open slots.'
                    : 'Every team is full right now. Check again later or wait for the Random Pool.',
                actionLabel: vm.hasCriteria ? 'Clear Filters' : null,
                onAction: vm.hasCriteria
                    ? () {
                        _search.clear();
                        vm.clearCriteria();
                      }
                    : null,
              ),
              builder: (context, teams) => Column(
                children: [
                  for (final t in teams) ...[_TeamCard(team: t), const SizedBox(height: AppSpacing.md)],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const InfoBanner(
              tone: Tone.neutral,
              icon: Icons.lightbulb_outline,
              title: "Can't find a good fit?",
              message:
                  'Students without a team at the deadline go to the Random Pool, '
                  'which matches them by role and skills.',
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    final open = team.openSlots;
    // Re-run the search on return: slots may have changed while on the detail screen.
    Future<void> openDetail() async {
      final vm = context.read<BrowseViewModel>();
      await context.push('/browse/team/${team.id}');
      await vm.search();
    }

    return AppCard(
      semanticId: 'team_card_${team.code}',
      onTap: openDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name, style: context.text.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(team.topic, style: context.text.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(
                label: open == 0 ? 'Full' : '$open ${open == 1 ? 'slot' : 'slots'} open',
                tone: open == 0 ? Tone.neutral : (open == 1 ? Tone.warning : Tone.success),
                icon: open == 0 ? Icons.block : Icons.person_add_alt_1,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SlotRow(memberInitials: [for (final m in team.members) m.initials], capacity: team.capacity),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              StatusBadge(label: team.category, tone: Tone.primary),
              for (final tag in team.tags.take(3)) StatusBadge(label: tag),
            ],
          ),
          if (team.openRoles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Looking for: ${team.openRoles.join(', ')}',
              style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            semanticId: 'btn_view_${team.code}',
            label: 'View Details',
            variant: AppButtonVariant.secondary,
            onPressed: openDetail,
          ),
        ],
      ),
    );
  }
}
