import 'package:flutter/material.dart';

/// Weather conditions represented in the Figma design, each with its own
/// background gradient (see [AppColors.backgroundGradient]).
enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  overcast,
  moderateRain,
}

/// Single source of truth for colors, extracted from the Figma design
/// (see `ui/*.svg` exports).
class AppColors {
  AppColors._();

  // Core / semantic
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryContainer = Color(0xFF4F378A);
  static const Color onSurface = Color(0xFF1D1B20);
  static const Color onSurfaceVariant = Color(0xFF494551);
  static const Color outline = Color(0xFF7A7582);
  static const Color outlineVariant = Color(0xFFCBC4D2);
  static const Color surface = Color(0xFFFDF7FF);
  static const Color surfaceContainerHigh = Color(0xFFECE6EE);
  static const Color error = Color(0xFFBA1A1A);

  // Accent (sun / warmth)
  static const Color tertiary = Color(0xFFE7C365);
  static const Color tertiaryDark = Color(0xFFC9A74D);
  static const Color onTertiaryContainer = Color(0xFF765B00);
  static const Color onTertiaryContainerDark = Color(0xFF503D00);

  // Splash / Home background gradient
  static const List<Color> splashGradient = [
    Color(0xFFFEF3C7),
    Color(0xFFEDE9FE),
    Color(0xFFDBEAFE),
  ];

  // Loading / Error background gradients (subtle, near-white)
  static const List<Color> loadingGradient = [
    Color(0xFFFDF7FF),
    Color(0xFFF2ECF4),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFFDF7FF),
    Color(0xFFE1D4FD),
  ];

  // Per-weather-condition background gradients
  static const List<Color> clearGradient = [
    Color(0xFFFFF0B8),
    Color(0xFFFFF8DC),
    Color(0xFFFFF4E8),
  ];

  static const List<Color> partlyCloudyGradient = [
    Color(0xFFFFF0B7),
    Color(0xFFD9E5EC),
    Color(0xFFEDF0E8),
    Color(0xFFFAF7ED),
  ];

  static const List<Color> cloudyGradient = [
    Color(0xFFDCE5EA),
    Color(0xFFE9EEF0),
    Color(0xFFF6F5F1),
  ];

  static const List<Color> overcastGradient = [
    Color(0xFFAEBCC5),
    Color(0xFFCBD2D5),
    Color(0xFFE5E6E2),
  ];

  static const List<Color> moderateRainGradient = [
    Color(0xFF8298A6),
    Color(0xFFA9BAC3),
    Color(0xFFD7E1E4),
  ];

  /// Returns the background gradient stops for a given [WeatherCondition],
  /// matching the "Current Weather" screens in the Figma design.
  static List<Color> backgroundGradient(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return clearGradient;
      case WeatherCondition.partlyCloudy:
        return partlyCloudyGradient;
      case WeatherCondition.cloudy:
        return cloudyGradient;
      case WeatherCondition.overcast:
        return overcastGradient;
      case WeatherCondition.moderateRain:
        return moderateRainGradient;
    }
  }
}
