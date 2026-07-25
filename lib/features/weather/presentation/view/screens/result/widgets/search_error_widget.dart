import 'package:aoreli_weather/core/config/themes/app_colors.dart';
import 'package:aoreli_weather/core/config/themes/app_padding.dart';
import 'package:flutter/material.dart';

class SearchErrorWidget extends StatelessWidget {
  const SearchErrorWidget({
    required this.message,
    required this.onTryAgainPressed,
    super.key,
  });

  final String message;
  final VoidCallback onTryAgainPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: AppPadding.screenBody,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.location_off_outlined,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "We couldn't find that city",
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTryAgainPressed,
              child: const Text('Try again'),
            ),
          ),
        ],
      ),
    );
  }
}
