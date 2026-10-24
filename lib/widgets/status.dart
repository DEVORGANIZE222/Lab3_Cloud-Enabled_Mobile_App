import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

enum Tone { neutral, primary, success, warning, error, info }

({Color fg, Color bg}) toneColors(BuildContext context, Tone tone) {
  final c = context.colors;
  final a = context.appColors;
  return switch (tone) {
    Tone.neutral => (fg: a.onTag, bg: a.tag),
    Tone.primary => (fg: c.onPrimaryContainer, bg: c.primaryContainer),
    Tone.success => (fg: a.success, bg: a.successContainer),
    Tone.warning => (fg: a.warning, bg: a.warningContainer),
    Tone.error => (fg: c.error, bg: c.errorContainer),
    Tone.info => (fg: a.info, bg: a.infoContainer),
  };
}

/// Status badge: always icon + text (WCAG 1.4.1, no meaning by colour alone).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = Tone.neutral, this.icon});

  final String label;
  final Tone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = toneColors(context, tone);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(color: t.bg, borderRadius: AppRadius.fullAll),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSize.iconSmall, color: t.fg),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge?.copyWith(color: t.fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline banner (info / success / warning / error) with a front-loaded title.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.title,
    this.message,
    this.tone = Tone.info,
    this.icon,
    this.action,
    this.semanticId,
  });

  final String title;
  final String? message;
  final Tone tone;
  final IconData? icon;
  final Widget? action;
  final String? semanticId;

  IconData get _defaultIcon => switch (tone) {
    Tone.success => Icons.check_circle,
    Tone.warning => Icons.schedule,
    Tone.error => Icons.error,
    _ => Icons.info,
  };

  @override
  Widget build(BuildContext context) {
    final t = toneColors(context, tone);
    return Semantics(
      identifier: semanticId,
      container: true,
      liveRegion: tone == Tone.error,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: t.fg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? _defaultIcon, color: t.fg),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.labelLarge?.copyWith(color: t.fg)),
                  if (message != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(message!, style: context.text.bodyMedium),
                  ],
                  if (action != null) ...[const SizedBox(height: AppSpacing.sm), action!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circle avatar with initials (or a dashed "open slot").
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, this.initials, this.size = AppSize.avatar});

  final String? initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (initials == null) {
      return Semantics(
        label: 'Open slot',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.outline),
          ),
          child: Icon(Icons.add, size: size / 2, color: c.onSurfaceVariant),
        ),
      );
    }
    // The outline keeps the avatar visible on tinted (selected) cards.
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.primaryContainer,
        border: Border.all(color: c.primary.withValues(alpha: 0.4)),
      ),
      child: Text(initials!, style: context.text.labelLarge?.copyWith(color: c.onPrimaryContainer)),
    );
  }
}

/// Lab 2 decision D1: capacity as visual slots (filled avatars + open slots).
class SlotRow extends StatelessWidget {
  const SlotRow({super.key, required this.memberInitials, required this.capacity});

  final List<String> memberInitials;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final open = (capacity - memberInitials.length).clamp(0, capacity);
    return Semantics(
      label: '${memberInitials.length} of $capacity members, $open open',
      excludeSemantics: true,
      child: Wrap(
        spacing: AppSpacing.sm,
        children: [
          for (final i in memberInitials) MemberAvatar(initials: i, size: AppSize.avatarSmall),
          for (var k = 0; k < open; k++) const MemberAvatar(size: AppSize.avatarSmall),
        ],
      ),
    );
  }
}

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, required this.label, this.tone = Tone.primary});

  final double value;
  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final t = toneColors(context, tone);
    return Semantics(
      label: label,
      value: '${(value * 100).round()} percent',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.fullAll,
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              color: tone == Tone.primary ? context.colors.primary : t.fg,
              minHeight: AppSize.progress,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: context.text.bodyMedium),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.titleMedium)),
          if (trailing != null) Text(trailing!, style: context.text.labelMedium),
        ],
      ),
    );
  }
}

/// Key-value row with a leading icon (Team Detail facts, Random Pool status).
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: context.text.bodyMedium),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(value, style: context.text.labelLarge, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
