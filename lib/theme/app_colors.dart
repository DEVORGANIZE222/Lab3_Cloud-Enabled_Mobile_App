import 'package:flutter/material.dart';

/// Design tokens from Lab 2 flutter-handoff.md
class AppColors {
  // Primary (Growth Green)
  static const Color primary = Color(0xFF15803D);
  static const Color primaryContainer = Color(0xFFDCFCE7);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Surface & Background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);

  // Text
  static const Color textPrimary = Color(0xFF1A1D1E);
  static const Color textSecondary = Color(0xFF596066);

  // Status & Semantic Colors
  static const Color success = Color(0xFF0F766E); // Verification Teal (Locked badge, filled slot)
  static const Color error = Color(0xFFBA1A1A);   // Error banner, destructive action
  static const Color warning = Color(0xFFB26A00); // Deadline urgent countdown
  static const Color border = Color(0xFFE1E3E5);  // Card outline, input borders
}
