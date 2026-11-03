import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/mentor.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../viewmodels/mentor_detail_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/states.dart';
import '../../widgets/status.dart';
import '../shared/feedback.dart';
import '../shared/profile_action.dart';

class MentorDetailScreen extends StatelessWidget {
  const MentorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MentorDetailViewModel>();
    return BlockingOverlay(
      visible: vm.isSubmitting || vm.isCancelling,
      message: vm.isSubmitting ? 'Sending request…' : 'Withdrawing request…',
      child: Scaffold(
        appBar: const AppTopBar(
          title: 'Mentor Profile',
          showBack: true,
          actions: [ProfileAction()],
        ),
        body: RefreshIndicator(
          onRefresh: vm.load,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              ViewStateView<Mentor>(
                state: vm.state,
                onRetry: vm.load,
                builder: (context, mentor) => _MentorDetailBody(mentor: mentor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MentorDetailBody extends StatelessWidget {
  const _MentorDetailBody({required this.mentor});

  final Mentor mentor;

  Future<void> _showRequestDialog(BuildContext context) async {
    final vm = context.read<MentorDetailViewModel>();
    final controller = TextEditingController(
      text: vm.myTeam != null
          ? 'Dear ${mentor.fullName},\n\nOur team ${vm.myTeam!.name} is working on "${vm.myTeam!.topic}". '
              'We would be honored to have your guidance as our Capstone supervisor.'
          : '',
    );

    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Request Mentorship', style: ctx.text.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send a proposal message to ${mentor.fullName} for team ${vm.myTeam?.name ?? ""}:',
                style: ctx.text.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: controller,
                label: 'Message to Mentor',
                hint: 'Introduce your project, goals, and why you chose this mentor…',
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          AppButton(
            label: 'Send Request',
            icon: Icons.send,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (sent == true && context.mounted) {
      final failure = await vm.sendRequest(controller.text);
      if (!context.mounted) return;
      if (failure != null) {
        showFailure(context, failure);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mentorship request sent to ${mentor.fullName}!')),
        );
      }
    }
  }

  Future<void> _cancelRequest(BuildContext context, String requestId) async {
    final vm = context.read<MentorDetailViewModel>();
    final confirmed = await showAppDialog(
      context,
      destructive: true,
      title: 'Withdraw Request?',
      message: 'Are you sure you want to withdraw your mentorship request to ${mentor.fullName}?',
      confirmLabel: 'Withdraw',
    );

    if (confirmed && context.mounted) {
      final failure = await vm.cancelRequest(requestId);
      if (!context.mounted) return;
      if (failure != null) {
        showFailure(context, failure);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mentorship request withdrawn.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MentorDetailViewModel>();
    final isAssigned = vm.isAssignedMentor(mentor);
    final pendingReq = vm.existingPendingRequest;
    final available = mentor.isAvailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Card
        AppCard(
          semanticId: 'card_mentor_header',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: context.colors.primaryContainer,
                child: Text(
                  mentor.initials,
                  style: context.text.headlineMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                mentor.fullName,
                style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                mentor.title,
                style: context.text.titleSmall?.copyWith(color: context.colors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                mentor.department,
                style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              StatusBadge(
                label: available ? '${mentor.remainingSlots} slots open' : 'Quota Full',
                tone: available ? Tone.success : Tone.neutral,
                icon: available ? Icons.check_circle : Icons.block,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Contact & Office Information
        AppCard(
          semanticId: 'card_mentor_contact',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact & Office', style: context.text.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 20, color: context.colors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(mentor.email, style: context.text.bodyMedium),
                  ),
                ],
              ),
              if (mentor.office.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 20, color: context.colors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(mentor.office, style: context.text.bodyMedium),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Capacity and Load
        AppCard(
          semanticId: 'card_mentor_quota',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mentorship Capacity', style: context.text.titleMedium),
                  Text(
                    '${mentor.currentAssigned} / ${mentor.maxQuota} Teams',
                    style: context.text.titleSmall?.copyWith(
                      color: available ? context.colors.primary : context.colors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.fullAll,
                child: LinearProgressIndicator(
                  value: (mentor.currentAssigned / mentor.maxQuota).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  color: available ? context.colors.primary : context.colors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                available
                    ? '${mentor.remainingSlots} more Capstone team(s) can be supervised.'
                    : 'Maximum supervision quota reached for this semester.',
                style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              if (mentor.mentoredTeamNames.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Currently Supervising:', style: context.text.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final t in mentor.mentoredTeamNames)
                      StatusBadge(label: t, tone: Tone.info, icon: Icons.groups),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Areas of Expertise
        AppCard(
          semanticId: 'card_mentor_expertise',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Areas of Expertise & Research', style: context.text.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final exp in mentor.expertise)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: AppRadius.fullAll,
                      ),
                      child: Text(
                        exp,
                        style: context.text.labelMedium?.copyWith(
                          color: context.colors.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Bio & Introduction
        AppCard(
          semanticId: 'card_mentor_bio',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About & Research Focus', style: context.text.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                mentor.bio,
                style: context.text.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Request Actions
        if (isAssigned) ...[
          InfoBanner(
            semanticId: 'banner_assigned_mentor',
            tone: Tone.success,
            title: 'Your Official Supervisor',
            message: '${mentor.fullName} is currently assigned as the supervisor for ${vm.myTeam!.name}.',
          ),
        ] else if (pendingReq != null) ...[
          AppCard(
            semanticId: 'card_pending_request',
            color: context.appColors.warningContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.hourglass_top, color: context.appColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Mentorship Request Pending',
                        style: context.text.titleSmall?.copyWith(
                          color: context.appColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const StatusBadge(label: 'Pending', tone: Tone.warning),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your team sent a proposal message. Awaiting response from ${mentor.fullName}.',
                  style: context.text.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  semanticId: 'btn_cancel_mentor_request',
                  label: 'Withdraw Request',
                  variant: AppButtonVariant.destructive,
                  icon: Icons.cancel_outlined,
                  onPressed: () => _cancelRequest(context, pendingReq.id),
                ),
              ],
            ),
          ),
        ] else if (!vm.hasTeam) ...[
          const InfoBanner(
            semanticId: 'banner_no_team_mentor',
            tone: Tone.info,
            title: 'Team Required to Request',
            message: 'You need to be part of a Capstone team before requesting a supervisor. Join or create a team first.',
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            semanticId: 'btn_browse_teams_for_mentor',
            label: 'Browse Teams',
            icon: Icons.search,
            onPressed: () => context.go('/browse'),
          ),
        ] else if (!available) ...[
          InfoBanner(
            semanticId: 'banner_mentor_full',
            tone: Tone.neutral,
            title: 'Quota Reached',
            message: '${mentor.fullName} cannot take more Capstone teams this semester. Please choose another mentor.',
          ),
        ] else ...[
          AppButton(
            semanticId: 'btn_request_mentor',
            label: 'Request Mentorship for ${vm.myTeam!.name}',
            icon: Icons.send,
            variant: AppButtonVariant.primary,
            onPressed: () => _showRequestDialog(context),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
