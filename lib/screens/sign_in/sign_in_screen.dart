import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../viewmodels/sign_in_viewmodel.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status.dart';

/// SCR_01 Sign In (Figma `SCR_01: Sign In (FPT SSO)`).
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  static const _steps = [
    (Icons.groups, Tone.warning, 'Form a 4–5 member team', 'Find teammates by role and skill before the deadline.'),
    (Icons.how_to_vote, Tone.info, 'Elect a team leader', 'Your team votes for one leader who submits the roster.'),
    (Icons.verified_user, Tone.success, 'Lock your roster', 'The leader sends the final team to the Academic Office.'),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignInViewModel>();
    final busy = vm.status == SignInStatus.signingIn;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSize.maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                const Center(
                  child: StatusBadge(
                    label: 'FPT University · Software Engineering',
                    tone: Tone.warning,
                    icon: Icons.school,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Semantics(
                    label: 'EXEMatching logo',
                    image: true,
                    child: Container(
                      width: AppSize.logo,
                      height: AppSize.logo,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerLowest,
                        borderRadius: AppRadius.cardAll,
                        boxShadow: cardShadow,
                      ),
                      child: Image.asset('assets/brand/logo.png'),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Semantics(
                  header: true,
                  child: Text('EXEMatching', textAlign: TextAlign.center, style: context.text.headlineMedium),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Spring 2026 Capstone team registration',
                  textAlign: TextAlign.center,
                  style: context.text.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xl),
                for (final (i, s) in _steps.indexed) ...[
                  AppCard(
                    color: context.colors.surfaceContainerHigh,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconTile(icon: s.$1, tone: s.$2),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(s.$3, style: context.text.titleSmall)),
                                  StatusBadge(label: 'Step 0${i + 1}'),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(s.$4, style: context.text.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.md),
                if (vm.message != null) ...[
                  InfoBanner(
                    semanticId: 'sign_in_message',
                    tone: vm.message!.code == 'cancelled' ? Tone.info : Tone.error,
                    title: vm.message!.title,
                    message: vm.message!.cause,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _GoogleButton(busy: busy, onPressed: vm.signIn),
                const SizedBox(height: AppSpacing.lg),
                InfoBanner(
                  tone: Tone.neutral,
                  icon: Icons.lock,
                  iconColor: context.colors.secondary,
                  title: 'Only class-roster accounts can sign in',
                  message: 'Use the Google email registered by the Academic Office for this class.',
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline, size: AppSize.iconSmall, color: context.colors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Need help with enrollment?', style: context.text.bodyMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Contact the Academic Office · academic@fpt.edu.vn',
                  textAlign: TextAlign.center,
                  style: context.text.labelMedium?.copyWith(color: context.colors.secondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma SCR_01 Google button: white card, Google "G", label, trailing arrow.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = busy ? 'Signing in…' : 'Continue with Google';
    return Semantics(
      identifier: 'btn_google_sign_in',
      button: true,
      enabled: !busy,
      label: busy ? '$label, in progress' : label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(borderRadius: AppRadius.cardAll, boxShadow: cardShadow),
        child: Material(
          color: context.colors.surfaceContainerLowest,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: busy ? null : onPressed,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    if (busy)
                      const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      const Text(
                        'G',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF4285F4)),
                      ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: Text(label, style: context.text.titleSmall)),
                    Icon(Icons.arrow_forward, color: context.colors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
