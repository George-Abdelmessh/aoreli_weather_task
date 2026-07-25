import 'package:flutter/material.dart';

import '../../../../../core/config/themes/app_colors.dart';

/// The rounded "search for a city" field reused across the Home, loading,
/// error, and result states.
class WeatherSearchField extends StatelessWidget {
  const WeatherSearchField({
    required this.controller,
    required this.onSubmitted,
    this.hasError = false,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final color = hasError ? AppColors.error : AppColors.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: hasError
              ? AppColors.error.withValues(alpha: 0.6)
              : Colors.transparent,
        ),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        style: TextStyle(color: hasError ? AppColors.error : null),
        decoration: InputDecoration(
          hintText: 'Search for a city',
          prefixIcon: Icon(Icons.location_on_outlined, color: color),
          suffixIcon: IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ),
            onPressed: () => onSubmitted(controller.text),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
