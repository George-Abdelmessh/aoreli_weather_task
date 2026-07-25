import 'package:flutter/material.dart';

import '../../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../../core/config/themes/app_padding.dart';

/// A single stat tile (humidity, wind, UV index, pressure) on the Result
/// screen.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.valueSuffix,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? valueSuffix;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: AppPadding.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.outline,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(icon, size: 16, color: AppColors.outline),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (valueSuffix != null)
              Text(
                valueSuffix!,
                style: textTheme.labelSmall?.copyWith(color: AppColors.outline),
              ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.outline,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
