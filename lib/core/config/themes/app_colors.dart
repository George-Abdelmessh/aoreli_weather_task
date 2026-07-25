import 'package:flutter/material.dart';

/// Weather conditions represented in the Figma design, each with its own
/// background gradient (see [AppColors.backgroundGradient]).
enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  overcast,
  moderateRain,

  /// weatherapi.com has ~50 distinct condition strings (e.g. "Blizzard",
  /// "Freezing fog", "Blowing snow") and the design only covers 5 of them.
  /// Anything that doesn't clearly match one of those falls back here, with
  /// its own neutral gradient (see [AppColors.defaultGradient]) rather than
  /// being silently misclassified as one of the named conditions.
  unknown;

  /// Maps a free-text condition (e.g. weatherapi.com's `condition.text`,
  /// such as "Sunny", "Patchy rain possible") to the closest
  /// [WeatherCondition] the design has a gradient for, or [unknown] if none
  /// of the recognized keywords match.
  factory WeatherCondition.fromApiText(String text) {
    final normalized = text.toLowerCase();

    if (normalized.contains('rain') ||
        normalized.contains('drizzle') ||
        normalized.contains('thunder') ||
        normalized.contains('storm')) {
      return WeatherCondition.moderateRain;
    }
    if (normalized.contains('overcast')) {
      return WeatherCondition.overcast;
    }
    if (normalized.contains('partly') || normalized.contains('patchy')) {
      return WeatherCondition.partlyCloudy;
    }
    if (normalized.contains('cloud') ||
        normalized.contains('fog') ||
        normalized.contains('mist')) {
      return WeatherCondition.cloudy;
    }
    if (normalized.contains('sunny') || normalized.contains('clear')) {
      return WeatherCondition.clear;
    }
    return WeatherCondition.unknown;
  }
}

/// Single source of truth for colors, extracted from the Figma design
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

  /// Neutral fallback for any condition the design doesn't have a specific
  /// gradient for (see [WeatherCondition.unknown]).
  static const List<Color> defaultGradient = [
    Color(0xFFE0E3E8),
    Color(0xFFEDEBF0),
    Color(0xFFF8F6FB),
  ];

  /// Returns the background gradient stops for a given [WeatherCondition],
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
      case WeatherCondition.unknown:
        return defaultGradient;
    }
  }
}
