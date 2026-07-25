import 'package:aoreli_weather/core/config/themes/app_colors.dart';
import 'package:aoreli_weather/core/utils/screen_size.dart';
import 'package:flutter/material.dart';

class CutsomButton extends StatelessWidget {
  const CutsomButton({
    required this.onPressed,
    required this.child,
    this.borderColor = AppColors.primary,
    this.backgroundColor = Colors.transparent,
    super.key,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Color borderColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: ScreenSize.heightScale(context, 45),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(child: child),
      ),
    );
  }
}
