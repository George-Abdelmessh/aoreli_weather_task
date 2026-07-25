import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/config/themes/app_colors.dart';
import '../../../../data/models/weather_model.dart';
import '../../../controller/weather_cubit.dart';
import '../../../controller/weather_state.dart';
import '../../shared_widgets/weather_search_field.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _searchController = TextEditingController();

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
    context.read<WeatherCubit>().fetchWeather(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        final gradient = state.when(
          initial: () => AppColors.splashGradient,
          loading: () => AppColors.loadingGradient,
          success: (weather) => AppColors.backgroundGradient(
            WeatherCondition.fromApiText(weather.conditionText),
          ),
          error: (_) => AppColors.errorGradient,
        );

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: state.when(
                  initial: () => _HomeContent(
                    controller: _searchController,
                    onSearch: _search,
                  ),
                  loading: () => _LoadingContent(
                    city: _searchController.text,
                  ),
                  success: (weather) => _WeatherResultContent(
                    weather: weather,
                    controller: _searchController,
                    onSearch: _search,
                  ),
                  error: (message) => _ErrorContent(
                    message: message,
                    controller: _searchController,
                    onSearch: _search,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'Aoreli',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        Text(
          'a weather app',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        Icon(
          Icons.wb_sunny_outlined,
          size: 64,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 20),
        Text(
          'Transform meteorological data\ninto atmospheric serenity.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Your Location',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        WeatherSearchField(controller: controller, onSubmitted: onSearch),
        const SizedBox(height: 8),
        Text(
          'TRY CAIRO, ALEXANDRIA, OR LONDON',
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onSearch(controller.text),
            child: const Text('View weather'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Location search isn't available yet."),
                ),
              );
            },
            icon: const Icon(Icons.near_me_outlined, size: 18),
            label: const Text('Use my location'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader({this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 18,
          color: AppColors.outline,
        ),
        const SizedBox(width: 4),
        if (subtitle != null)
          Text(
            subtitle!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.outline),
          ),
        const Spacer(),
        Text(
          'Aoreli',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent({required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(height: 16),
        const _CompactHeader(),
        const Spacer(),
        Icon(
          Icons.wb_sunny_outlined,
          size: 56,
          color: AppColors.tertiaryDark.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 20),
        const CircularProgressIndicator(strokeWidth: 2),
        const SizedBox(height: 20),
        Text(
          'Checking the weather in $city...',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          'This should only take a moment.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.outline),
        ),
        const Spacer(),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({
    required this.message,
    required this.controller,
    required this.onSearch,
  });

  final String message;
  final TextEditingController controller;
  final ValueChanged<String> onSearch;

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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final friendlyMessage = _friendlyMessages[message] ?? message;

    return Column(
      children: [
        const SizedBox(height: 16),
        const _CompactHeader(),
        const SizedBox(height: 16),
        WeatherSearchField(
          controller: controller,
          onSubmitted: onSearch,
          hasError: true,
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
          style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          friendlyMessage,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.outline),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onSearch(controller.text),
            child: const Text('Try again'),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _WeatherResultContent extends StatelessWidget {
  const _WeatherResultContent({
    required this.weather,
    required this.controller,
    required this.onSearch,
  });

  final WeatherModel weather;
  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(height: 16),
        _CompactHeader(subtitle: weather.cityName),
        const SizedBox(height: 16),
        WeatherSearchField(controller: controller, onSubmitted: onSearch),
        const Spacer(),
        Text(
          '${weather.temperature.round()}°C',
          style: textTheme.displayMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: weather.conditionIconUrl,
              width: 32,
              height: 32,
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            Text(
              weather.conditionText,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }
}
