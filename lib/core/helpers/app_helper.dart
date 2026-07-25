import 'package:flutter/material.dart';

class AppHelpers {
  /// Physics list view
  static BouncingScrollPhysics scroll = const BouncingScrollPhysics();

  /// CLOSE KEYBOARD
  static Future closeKeyboard() async {
    /// CLOSE KEYBOARD
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
