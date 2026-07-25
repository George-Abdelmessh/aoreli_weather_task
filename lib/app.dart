import 'package:aoreli_weather/core/helpers/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/themes/app_theme.dart';
import 'core/di/service_locator.dart';
import 'features/splash/presentation/view/screens/splash/splash_screen.dart';
import 'features/weather/presentation/controller/weather_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WeatherCubit>(
      create: (_) => sl<WeatherCubit>(),
      child: GestureDetector(
        onTap: AppHelpers.closeKeyboard,
        child: MaterialApp(
          title: 'Aoreli Weather',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
