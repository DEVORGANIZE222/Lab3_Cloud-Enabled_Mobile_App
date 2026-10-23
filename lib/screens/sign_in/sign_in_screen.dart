import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../viewmodels/sign_in_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status.dart';

/// SCR_01 Sign In (Figma `SCR_01: Sign In (FPT SSO)`).
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  static const _steps = [
    (Icons.groups, 'Form a 4–5 member team', 'Find teammates by role and skill before the deadline.'),
    (Icons.how_to_vote, 'Elect a team leader', 'Your team votes for one leader who submits the roster.'),
    (Icons.verified_user, 'Lock your roster', 'The leader sends the final team to the Academic Office.'),
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
                  child: StatusBadge(label: 'FPT University · Software Engineering', tone: Tone.primary),
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Semantics(
                    label: 'EXEMatching logo',
                    image: true,
                    child: Image.asset('assets/brand/logo.png', width: AppSize.logo, height: AppSize.logo),
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
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: context.colors.primaryContainer,
                          child: Icon(s.$1, color: context.colors.onPrimaryContainer),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(s.$2, style: context.text.titleSmall)),
                                  StatusBadge(label: 'Step ${i + 1}'),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(s.$3, style: context.text.bodyMedium),
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
                AppButton(
                  semanticId: 'btn_google_sign_in',
                  label: busy ? 'Signing in…' : 'Continue with Google',
                  icon: Icons.login,
                  loading: busy,
                  onPressed: vm.signIn,
                ),
                const SizedBox(height: AppSpacing.lg),
                const InfoBanner(
                  tone: Tone.neutral,
                  icon: Icons.lock_outline,
                  title: 'Only @fpt.edu.vn accounts can sign in',
                  message: 'Use the Google account the university gave you.',
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Need help? Contact the Academic Office at academic@fpt.edu.vn.',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
