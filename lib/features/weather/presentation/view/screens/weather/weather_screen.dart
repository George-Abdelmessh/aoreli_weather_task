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
  bool _isFahrenheit = false;

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

  void _toggleUnit() {
    setState(() => _isFahrenheit = !_isFahrenheit);
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
              child: state.when(
                initial: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _HomeContent(
                    controller: _searchController,
                    onSearch: _search,
                  ),
                ),
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _LoadingContent(city: _searchController.text),
                ),
                success: (weather) => _WeatherResultContent(
                  weather: weather,
                  controller: _searchController,
                  onSearch: _search,
                  isFahrenheit: _isFahrenheit,
                  onToggleUnit: _toggleUnit,
                ),
                error: (message) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _ErrorContent(
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
  const _CompactHeader();

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
    required this.isFahrenheit,
    required this.onToggleUnit,
  });

  final WeatherModel weather;
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final bool isFahrenheit;
  final VoidCallback onToggleUnit;

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  double get _displayTemp =>
      isFahrenheit ? weather.temperatureC * 9 / 5 + 32 : weather.temperatureC;

  double get _displayFeelsLike =>
      isFahrenheit ? weather.feelsLikeC * 9 / 5 + 32 : weather.feelsLikeC;

  String get _unitSuffix => isFahrenheit ? '°F' : '°C';

  static String _formatTime(DateTime dt) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }

  static String _formatDateHeading(DateTime dt) {
    final weekday = _weekdays[dt.weekday - 1];
    final month = _months[dt.month - 1];
    return '${_formatTime(dt)} • ${weekday.toUpperCase()}, '
        '${dt.day} ${month.toUpperCase()} ${dt.year}';
  }

  static String _uvLabel(double uv) {
    if (uv <= 2) {
      return 'LOW';
    }
    if (uv <= 5) {
      return 'MODERATE';
    }
    if (uv <= 7) {
      return 'HIGH';
    }
    if (uv <= 10) {
      return 'VERY HIGH';
    }
    return 'EXTREME';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  'Aoreli',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                _UnitToggle(
                  isFahrenheit: isFahrenheit,
                  onToggle: onToggleUnit,
                ),
              ],
            ),
            const SizedBox(height: 16),
            WeatherSearchField(controller: controller, onSubmitted: onSearch),
            const SizedBox(height: 20),
            Text(
              [
                weather.cityName,
                weather.region,
                weather.country,
              ].where((s) => s.isNotEmpty).join(', '),
              style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateHeading(weather.localTime),
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.outline,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_displayTemp.round()}°',
                  style: textTheme.displayMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 2),
                  child: Text(
                    isFahrenheit ? 'F' : 'C',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: weather.conditionIconUrl,
                  width: 24,
                  height: 24,
                  errorWidget: (context, url, error) =>
                      const SizedBox.shrink(),
                ),
                const SizedBox(width: 6),
                Text(
                  weather.conditionText,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Feels like ${_displayFeelsLike.round()}$_unitSuffix • '
              'Updated at ${_formatTime(weather.lastUpdated)}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.water_drop_outlined,
                    label: 'HUMIDITY',
                    value: '${weather.humidity}%',
                    caption:
                        'The dew point is ${weather.dewPointC.round()}° '
                        'right now.',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.air,
                    label: 'WIND',
                    value: weather.windKph.toStringAsFixed(1),
                    valueSuffix: 'KM/H ${weather.windDir}',
                    caption: 'Gusts up to ${weather.gustKph.round()} km/h.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.wb_sunny_outlined,
                    label: 'UV INDEX',
                    value: weather.uv.toStringAsFixed(1),
                    valueSuffix: _uvLabel(weather.uv),
                    caption: weather.uv >= 3
                        ? 'Use sun protection if outdoors.'
                        : 'Minimal risk right now.',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.speed_outlined,
                    label: 'PRESSURE',
                    value: weather.pressureMb.round().toString(),
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
                padding: const EdgeInsets.all(16),
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
                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            label: 'WIND DIRECTION',
                            value:
                                '${weather.windDir} (${weather.windDegree}°)',
                          ),
                        ),
                        Expanded(
                          child: _DetailItem(
                            label: 'PRECIPITATION',
                            value: '${weather.precipMm} mm',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            label: 'CLOUD COVER',
                            value: '${weather.cloud}%',
                          ),
                        ),
                        Expanded(
                          child: _DetailItem(
                            label: 'RAIN CHANCE',
                            value: '${weather.chanceOfRain}%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            label: 'HEAT INDEX',
                            value: '${weather.heatIndexC.round()}°C',
                          ),
                        ),
                        Expanded(
                          child: _DetailItem(
                            label: 'WIND CHILL',
                            value: '${weather.windChillC.round()}°C',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            label: 'VISIBILITY',
                            value: '${weather.visKm.round()} km',
                          ),
                        ),
                        Expanded(
                          child: _DetailItem(
                            label: 'DEW POINT',
                            value: '${weather.dewPointC.round()}°C',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.isFahrenheit, required this.onToggle});

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
          padding: const EdgeInsets.all(4),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.valueSuffix,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? valueSuffix;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.outline,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(icon, size: 16, color: AppColors.outline),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (valueSuffix != null)
              Text(
                valueSuffix!,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.outline,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.outline,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.outline,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
