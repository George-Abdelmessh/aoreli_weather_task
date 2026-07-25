import 'package:flutter/material.dart';

import '../../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../../core/config/themes/app_padding.dart';

/// Shown above the weather card when the displayed data came from the
/// offline cache instead of a fresh API response.
class OfflineCacheBanner extends StatelessWidget {
  const OfflineCacheBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.onTertiaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.md,
          vertical: AppPadding.sm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 16,
              color: AppColors.onTertiaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Showing last saved result — you're offline",
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
