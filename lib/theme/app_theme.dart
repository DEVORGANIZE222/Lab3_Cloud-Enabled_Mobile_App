import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

/// Lab 2 type scale (`DESIGN.md` §2). Roboto is the platform font on Android,
/// which the brief allows ("Inter or Roboto"), so no font asset is bundled.
TextTheme _textTheme(ColorScheme c) {
  TextStyle s(double size, double height, FontWeight weight, [Color? color]) => TextStyle(
    fontSize: size,
    height: height / size,
    fontWeight: weight,
    color: color ?? c.onSurface,
    letterSpacing: 0,
  );
  return TextTheme(
    headlineMedium: s(28, 34, FontWeight.w700), // type-display
    titleLarge: s(22, 28, FontWeight.w600), // type-headline (screen / app bar title)
    titleMedium: s(18, 24, FontWeight.w600), // type-title (card heading)
    titleSmall: s(16, 22, FontWeight.w600), // card name
    bodyLarge: s(16, 24, FontWeight.w400),
    bodyMedium: s(14, 20, FontWeight.w400), // type-body
    labelLarge: s(14, 20, FontWeight.w500), // type-label (buttons, chips)
    labelMedium: s(14, 20, FontWeight.w500, c.onSurfaceVariant),
    bodySmall: s(12, 16, FontWeight.w400, c.onSurfaceVariant), // type-caption (timestamps only)
  );
}

ThemeData buildAppTheme() {
  final c = appColorScheme;
  final t = _textTheme(c);
  const buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.smAll);
  const minButton = Size(AppSize.touchTarget, AppSize.button);

  return ThemeData(
    useMaterial3: true,
    colorScheme: c,
    textTheme: t,
    scaffoldBackgroundColor: c.surface,
    extensions: const [AppColors.light],
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    appBarTheme: AppBarTheme(
      backgroundColor: c.surfaceContainerLowest,
      foregroundColor: c.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: AppElevation.none,
      scrolledUnderElevation: AppElevation.card,
      centerTitle: false,
      toolbarHeight: AppSize.appBar,
      titleTextStyle: t.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: minButton,
        shape: buttonShape,
        textStyle: t.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        disabledBackgroundColor: AppPalette.disabled,
        disabledForegroundColor: AppPalette.onDisabled,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: minButton,
        shape: buttonShape,
        textStyle: t.labelLarge,
        foregroundColor: c.primary,
        side: BorderSide(color: c.outline),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: minButton,
        shape: buttonShape,
        textStyle: t.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size.square(AppSize.touchTarget)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: c.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: c.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: c.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: c.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: c.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.smAll,
        borderSide: BorderSide(color: c.outlineVariant),
      ),
      labelStyle: t.labelLarge,
      helperStyle: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
      errorStyle: t.bodyMedium?.copyWith(color: c.error),
      hintStyle: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
    ),
    cardTheme: CardThemeData(
      color: c.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: AppElevation.none,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(color: c.outlineVariant),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: AppSize.navBar,
      backgroundColor: c.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => t.labelLarge?.copyWith(color: s.contains(WidgetState.selected) ? c.onSurface : c.onSurfaceVariant),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? c.onPrimaryContainer : c.onSurfaceVariant),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: AppElevation.dialog,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      titleTextStyle: t.titleLarge,
      contentTextStyle: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: c.outline),
      selectedColor: c.primaryContainer,
      backgroundColor: c.surfaceContainerLowest,
      labelStyle: t.labelLarge,
      checkmarkColor: c.onPrimaryContainer,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.inverseSurface,
      contentTextStyle: t.bodyMedium?.copyWith(color: c.onInverseSurface),
      actionTextColor: c.inversePrimary,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primary,
      linearTrackColor: AppPalette.tag,
      linearMinHeight: AppSize.progress,
    ),
    dividerTheme: DividerThemeData(color: c.outlineVariant, space: AppSpacing.lg),
  );
}
