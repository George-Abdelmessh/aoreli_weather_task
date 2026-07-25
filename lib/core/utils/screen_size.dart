import 'package:flutter/material.dart';

/// Responsive scaling helper based on a design 
/// Example: iPhone 14 (390 x 844 logical points).
///
/// Use [widthScale] / [heightScale] for spacing, sizes, and icons.
/// Use [fontScale] for text — it clamps more conservatively than the
/// others since oversized/undersized text hurts readability more than
/// slightly-off spacing does.
class ScreenSize {
  ScreenSize._();

  // Base dimensions for iPhone 14 (logical points)
  static const double _baseWidth = 390;
  static const double _baseHeight = 844;


  /// Scales a width-based value (padding, icon size, horizontal spacing).
  ///
  /// Clamped between 0.8x and 1.3x so large screens (tablets) don't blow
  /// sizes up disproportionately, and very small screens don't shrink
  /// them past usability.
  static double widthScale(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / _baseWidth).clamp(0.8, 1.3);
    return size * scale;
  }

  /// Scales a height-based value (vertical spacing, card height).
  ///
  /// Uses the safe-area-adjusted height so device notches/status bars/
  /// home indicators don't skew the ratio.
  static double heightScale(BuildContext context, double size) {
    final mediaQuery = MediaQuery.of(context);
    final safeHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    const baseSafeHeight = _baseHeight - 47;
    final scale = (safeHeight / baseSafeHeight).clamp(0.8, 1.3);
    return size * scale;
  }

  /// Scales font sizes specifically.
  ///
  /// Tighter clamp range than [widthScale] — text becoming 30% larger on
  /// a tablet is often fine, but you rarely want body text scaling much
  /// beyond 1.15x or shrinking below 0.9x before it hurts readability.
  static double fontScale(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / _baseWidth).clamp(0.9, 1.15);
    return size * scale;
  }


  /// Screen width helper, so call sites don't need a raw MediaQuery call.
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Screen height helper, so call sites don't need a raw MediaQuery call.
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
}
