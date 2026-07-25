import 'package:flutter/material.dart';

/// Single source of truth for spacing/padding values, extracted from the
/// Figma design. Mirrors `AppColors` — reach for these instead of
/// hardcoding numbers in `EdgeInsets`/`SizedBox`.
class AppPadding {
  AppPadding._();

  // Base 4pt spacing scale.
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Standard horizontal inset used on every screen's edges.
  static const double screenHorizontal = xxl;

  /// Padding for a scrollable screen body that starts right below a
  /// `ScreenHeader` (Result, Error) — less top space since the header
  /// already carries its own spacing above the content.
  static const EdgeInsets screenBody = EdgeInsets.fromLTRB(xxl, lg, xxl, xxxl);

  /// Padding for a scrollable screen body with no header above it
  /// (Search).
  static const EdgeInsets screenBodyNoHeader = EdgeInsets.fromLTRB(
    xxl,
    xxl,
    xxl,
    xxxl,
  );

  /// Padding for card-like containers (stat cards, detail card, skeleton).
  static const EdgeInsets card = EdgeInsets.all(lg);
}
