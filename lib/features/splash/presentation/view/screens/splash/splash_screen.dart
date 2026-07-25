import 'dart:async';

import 'package:aoreli_weather/core/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../core/di/service_locator.dart';
import '../../../../../../core/helpers/app_navigator.dart';
import '../../../../../weather/presentation/controller/weather_cubit.dart';
import '../../../../../weather/presentation/view/screens/weather/weather_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _gradientFadeDelay = Duration(microseconds: 500);
  static const _gradientFadeDuration = Duration(milliseconds: 800);

  Timer? _navigationTimer;
  Timer? _gradientFadeTimer;
  bool _showGradient = false;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 3), _navigateToHome);
    _gradientFadeTimer = Timer(_gradientFadeDelay, () {
      if (!mounted) {
        return;
      }
      setState(() => _showGradient = true);
    });
  }

  void _navigateToHome() {
    if (!mounted) {
      return;
    }
    AppNavigator.pushReplacement(
      context: context,
      screen: BlocProvider<WeatherCubit>(
        create: (_) => sl<WeatherCubit>(),
        child: const WeatherScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _gradientFadeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _showGradient ? 1 : 0,
              duration: _gradientFadeDuration,
              curve: Curves.easeIn,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.splashGradient,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AORELI',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: ScreenSize.fontScale(context, 60),
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'a weather app',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: ScreenSize.fontScale(context, 16),
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
