import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Lab 2 *Card*: default (border, no shadow) and pressed (ink + level-1 tint).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.borderColor,
    this.semanticId,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final String? semanticId;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Semantics(
      identifier: semanticId,
      label: semanticLabel,
      button: onTap != null,
      container: true,
      child: Material(
        color: color ?? c.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: borderColor ?? c.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Lab 2 *Card · Selectable*: selected = 2 dp primary border + tint + filled
/// radio, so selection is never shown by colour alone.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.semanticId,
    this.semanticLabel,
  });

  final bool selected;
  final VoidCallback? onTap;
  final Widget child;
  final String? semanticId;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Semantics(
      identifier: semanticId,
      label: semanticLabel,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Material(
          color: selected ? c.primaryContainer : c.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
            side: BorderSide(color: selected ? c.primary : c.outlineVariant, width: selected ? 2 : 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(child: child),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: selected ? c.primary : c.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
