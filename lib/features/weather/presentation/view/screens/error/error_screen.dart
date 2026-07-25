import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../core/config/themes/app_padding.dart';
import '../../../../../../core/helpers/app_navigator.dart';
import '../../../../data/params/get_weather_params.dart';
import '../../../controller/weather_cubit.dart';
import '../../shared_widgets/screen_header.dart';
import '../../../../../shared/custom_widgets/cutom_input.dart';
import '../result/result_screen.dart';

/// Shown when a weather fetch fails for [city]. Reached via
/// [AppNavigator.pushReplacement] from [ResultScreen]; redirects back to a
/// (new) [ResultScreen] — again replacing itself — if a retry succeeds.
class ErrorScreen extends StatefulWidget {
  const ErrorScreen({required this.city, required this.message, super.key});

  final String city;
  final String message;

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  late final _searchController = TextEditingController(text: widget.city);

  static const Map<String, String> _friendlyMessages = {
    'failure.no_internet':
        "You're offline. Check your connection and try again.",
    'failure.server_error':
        'Something went wrong on our end. Please try again shortly.',
    'failure.unauthorized': "We couldn't authenticate this request.",
    'failure.forbidden': 'This request was blocked.',
    'failure.not_found': "We couldn't find what you were looking for.",
    'failure.rate_limit': 'Too many requests. Please wait and try again.',
    'failure.unexpected': 'An unexpected error occurred.',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String city) {
    final trimmed = city.trim();
    if (trimmed.isEmpty) {
      return;
    }
    context.read<WeatherCubit>().fetchWeather(GetWeatherParams(city: trimmed));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WeatherCubit, WeatherState>(
      listener: (context, state) {
        if (state is WeatherSuccess) {
          AppNavigator.pushReplacement(
            context: context,
            screen: ResultScreen(city: _searchController.text),
          );
        }
      },
      builder: (context, state) {
        final message = state is WeatherError ? state.message : widget.message;
        final friendlyMessage = _friendlyMessages[message] ?? message;
        final isRetrying = state is WeatherLoading;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.errorGradient,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.screenHorizontal,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ScreenHeader(
                      onBack: () => AppNavigator.pop(context: context),
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      controller: _searchController,
                      onSubmitted: _search,
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.location_off_outlined,
                        size: 40,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "We couldn't find that city",
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      friendlyMessage,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isRetrying
                            ? null
                            : () => _search(_searchController.text),
                        child: isRetrying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Try again'),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
