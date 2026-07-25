import 'package:flutter/material.dart';

import '../../../core/config/themes/app_colors.dart';

/// The rounded "search for a city" field reused across the Home, loading,
/// error, and result states.
class CustomInput extends StatelessWidget {
  const CustomInput({
    required this.controller,
    required this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onFieldSubmitted: onSubmitted,
      validator: validator ?? (val) => null,
      decoration: InputDecoration(
        hintText: hintText,
        errorBorder: _border(AppColors.error.withValues(alpha: 0.6)),
        border: _border(Colors.grey),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.6),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
