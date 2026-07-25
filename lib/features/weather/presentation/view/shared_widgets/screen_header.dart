import 'package:flutter/material.dart';

import '../../../../../core/config/themes/app_colors.dart';

/// Header row shown on pushed screens (Result, Error): a back button that
/// pops back to the Search screen, the "Aoreli" title, and an optional
/// trailing widget (e.g. the °C/°F toggle on the Result screen).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({required this.onBack, this.trailing, super.key});

  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: AppColors.outline),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 8),
        Text(
          'Aoreli',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}
