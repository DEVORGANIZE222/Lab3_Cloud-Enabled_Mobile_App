import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

enum AppButtonVariant { primary, secondary, destructive, text }

/// Lab 2 *Button*: Type × State (default, pressed, disabled, loading).
///
/// Pressed is the Material ink state; disabled is `onPressed == null`;
/// loading shows a spinner, keeps the label and blocks taps.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.semanticId,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  /// Stable id exposed to the accessibility tree (Android resource-id) for E2E tests.
  final String? semanticId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final callback = loading ? null : onPressed;
    final fg = switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.destructive => colors.onPrimary,
      _ => colors.primary,
    };

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: variant == AppButtonVariant.primary || variant == AppButtonVariant.destructive
                    ? colors.onPrimary
                    : colors.primary,
              ),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Icon(icon, size: 20, color: callback == null ? null : fg),
          ),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1)),
      ],
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(onPressed: callback, child: content),
      AppButtonVariant.destructive => FilledButton(
        onPressed: callback,
        style: FilledButton.styleFrom(backgroundColor: colors.error, foregroundColor: colors.onError),
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(onPressed: callback, child: content),
      AppButtonVariant.text => TextButton(onPressed: callback, child: content),
    };

    return Semantics(
      identifier: semanticId,
      button: true,
      enabled: callback != null,
      label: loading ? '$label, in progress' : null,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
