import 'package:flutter/material.dart';

/// Spacing and Radius tokens from Lab 2 flutter-handoff.md
class AppSpacing {
  static const double xs = 4.0;   // Micro vertical padding
  static const double sm = 8.0;   // Icon-to-text spacing, chip gap
  static const double md = 12.0;  // Compact card internal padding
  static const double lg = 16.0;  // Standard screen horizontal margin
  static const double xl = 24.0;  // Section vertical rhythm
  static const double xxl = 32.0; // Top hero padding

  // Touch target accessibility constraint: >= 48dp
  static const double minTouchTarget = 48.0;
}

class AppRadius {
  static const double sm = 8.0;   // Buttons, text inputs, chips
  static const double md = 12.0;  // Cards, bottom sheets
  static const double lg = 16.0;  // Modal dialogs

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
}
