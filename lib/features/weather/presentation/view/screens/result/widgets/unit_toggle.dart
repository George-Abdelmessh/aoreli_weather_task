import 'package:flutter/material.dart';

import '../../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../../core/config/themes/app_padding.dart';

/// The °C/°F pill toggle shown in the Result screen header.
class UnitToggle extends StatelessWidget {
  const UnitToggle({
    required this.isFahrenheit,
    required this.onToggle,
    super.key,
  });

  final bool isFahrenheit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UnitPill(label: '°C', selected: !isFahrenheit),
              _UnitPill(label: '°F', selected: isFahrenheit),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitPill extends StatelessWidget {
  const _UnitPill({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
