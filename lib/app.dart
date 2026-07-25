import 'package:flutter/material.dart';

import 'core/config/themes/app_theme.dart';
import 'features/splash/presentation/view/screens/splash/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aoreli Weather',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
