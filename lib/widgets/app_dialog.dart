import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_button.dart';

/// Lab 2 *Dialog*: confirmation and destructive. Buttons are stacked full width,
/// confirm first, so long labels never truncate at 360 dp (Lab 2 decision D9).
/// Returns `true` when the user confirms.
Future<bool> showAppDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
  IconData? icon,
  Widget? details,
  String? semanticId,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final c = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: Icon(
          icon ?? (destructive ? Icons.warning_amber_rounded : Icons.info_outline),
          color: destructive ? c.error : c.primary,
        ),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[const SizedBox(height: AppSpacing.lg), details],
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: confirmLabel,
                semanticId: semanticId == null ? null : '${semanticId}_confirm',
                variant: destructive ? AppButtonVariant.destructive : AppButtonVariant.primary,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: cancelLabel,
                semanticId: semanticId == null ? null : '${semanticId}_cancel',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ],
      );
    },
  );
  return result ?? false;
}
