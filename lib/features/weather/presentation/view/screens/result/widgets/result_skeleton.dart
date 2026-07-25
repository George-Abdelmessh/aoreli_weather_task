import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../../core/config/themes/app_padding.dart';
import 'detail_item.dart';
import 'stat_card.dart';

/// Shimmering placeholder that mirrors the real result layout, so the
/// loading state previews the shape of the data about to arrive.
class ResultSkeleton extends StatelessWidget {
  const ResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cairo, Al Qahirah, Egypt',
            style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            'WEDNESDAY, 22 JULY 2026',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.outline,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '41°',
            style: textTheme.displayMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 24),
              const SizedBox(width: 6),
              Text(
                'Sunny',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.water_drop_outlined,
                  label: 'HUMIDITY',
                  value: '44%',
                  caption: 'The dew point is 9° right now.',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.air,
                  label: 'WIND',
                  value: '34.6',
                  valueSuffix: 'KM/H NW',
                  caption: 'Gusts up to 41 km/h.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.wb_sunny_outlined,
                  label: 'UV INDEX',
                  value: '0.2',
                  valueSuffix: 'LOW',
                  caption: 'Minimal risk right now.',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.speed_outlined,
                  label: 'PRESSURE',
                  value: '1007',
                  valueSuffix: 'MB',
                  caption: 'Current barometric pressure.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: AppPadding.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S DETAILS",
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.outline,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: DetailItem(
                          label: 'WIND DIRECTION',
                          value: 'NW (318°)',
                        ),
                      ),
                      Expanded(
                        child: DetailItem(
                          label: 'PRECIPITATION',
                          value: '0 mm',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: DetailItem(label: 'CLOUD COVER', value: '0%'),
                      ),
                      Expanded(
                        child: DetailItem(label: 'RAIN CHANCE', value: '1%'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: DetailItem(label: 'HEAT INDEX', value: '39°C'),
                      ),
                      Expanded(
                        child: DetailItem(label: 'WIND CHILL', value: '39°C'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: DetailItem(label: 'VISIBILITY', value: '10 km'),
                      ),
                      Expanded(
                        child: DetailItem(label: 'DEW POINT', value: '9°C'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
