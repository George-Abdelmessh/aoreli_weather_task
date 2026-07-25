import 'package:flutter/material.dart';

import '../../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../../core/config/themes/app_padding.dart';

/// A single recent-search row on the Search screen.
class RecentSearchTile extends StatelessWidget {
  const RecentSearchTile({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              const Icon(Icons.history, size: 18, color: AppColors.outline),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
