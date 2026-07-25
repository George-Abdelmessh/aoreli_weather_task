import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../core/config/themes/app_padding.dart';
import '../../../../../../core/helpers/app_navigator.dart';
import '../../../../../shared/custom_widgets/cutom_input.dart';
import '../../../../data/models/weather_model.dart';
import '../../../../data/params/get_weather_params.dart';
import '../../../controller/weather_cubit.dart';
import '../../shared_widgets/screen_header.dart';
import '../error/error_screen.dart';
import 'widgets/detail_item.dart';
import 'widgets/offline_cache_banner.dart';
import 'widgets/result_skeleton.dart';
import 'widgets/stat_card.dart';
import 'widgets/unit_toggle.dart';

/// Shows the fetch-in-progress skeleton and, once it resolves, the weather
/// for [city]. Reached via [AppNavigator.push] from Search; redirects to
/// [ErrorScreen] (replacing itself) if the fetch fails.
class ResultScreen extends StatefulWidget {
  const ResultScreen({required this.city, super.key});

  final String city;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final _searchController = TextEditingController(text: widget.city);
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
    context.read<WeatherCubit>().fetchWeather(GetWeatherParams(city: trimmed));
  }

  void _toggleUnit() {
    setState(() => _isFahrenheit = !_isFahrenheit);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WeatherCubit, WeatherState>(
      listener: (context, state) {
        if (state is WeatherError) {
          AppNavigator.pushReplacement(
            context: context,
            screen: ErrorScreen(
              city: _searchController.text,
              message: state.message,
            ),
          );
        }
      },
      builder: (context, state) {
        final gradient = state is WeatherSuccess
            ? AppColors.backgroundGradient(
                WeatherCondition.fromApiText(
                  state.weather.current.condition.text,
                ),
              )
            : AppColors.loadingGradient;

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
              child: state is WeatherSuccess
                  ? _ResultBody(
                      weather: state.weather,
                      isCached: state.isCached,
                      controller: _searchController,
                      onSearch: _search,
                      isFahrenheit: _isFahrenheit,
                      onToggleUnit: _toggleUnit,
                    )
                  : _ResultLoadingBody(controller: _searchController),
            ),
          ),
        );
      },
    );
  }
}

class _ResultLoadingBody extends StatelessWidget {
  const _ResultLoadingBody({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final city = controller.text.trim();

    return SingleChildScrollView(
      padding: AppPadding.screenBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(onBack: () => AppNavigator.pop(context: context)),
          const SizedBox(height: 16),
          CustomInput(controller: controller, onSubmitted: (_) {}),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  size: 48,
                  color: AppColors.tertiaryDark.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  city.isEmpty
                      ? 'Checking the weather...'
                      : 'Checking the weather in $city...',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This should only take a moment.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const ResultSkeleton(),
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.weather,
    required this.controller,
    required this.onSearch,
    required this.isFahrenheit,
    required this.onToggleUnit,
    this.isCached = false,
  });

  final WeatherModel weather;
  final bool isCached;
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
      isFahrenheit ? weather.current.tempC * 9 / 5 + 32 : weather.current.tempC;

  double get _displayFeelsLike => isFahrenheit
      ? weather.current.feelslikeC * 9 / 5 + 32
      : weather.current.feelslikeC;

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

    return SingleChildScrollView(
      padding: AppPadding.screenBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(
            onBack: () => AppNavigator.pop(context: context),
            trailing: UnitToggle(
              isFahrenheit: isFahrenheit,
              onToggle: onToggleUnit,
            ),
          ),
          const SizedBox(height: 16),
          CustomInput(controller: controller, onSubmitted: onSearch),
          if (isCached) ...[
            const SizedBox(height: 12),
            const OfflineCacheBanner(),
          ],
          const SizedBox(height: 20),
          Text(
            [
              weather.location.name,
              weather.location.region,
              weather.location.country,
            ].where((s) => s.isNotEmpty).join(', '),
            style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            _formatDateHeading(weather.location.localtime),
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
                imageUrl: weather.current.condition.iconUrl,
                width: 24,
                height: 24,
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 6),
              Text(
                weather.current.condition.text,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Feels like ${_displayFeelsLike.round()}$_unitSuffix • '
            'Updated at ${_formatTime(weather.current.lastUpdated)}',
            style: textTheme.bodySmall?.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.water_drop_outlined,
                  label: 'HUMIDITY',
                  value: '${weather.current.humidity}%',
                  caption:
                      'The dew point is '
                      '${weather.current.dewpointC.round()}° right now.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.air,
                  label: 'WIND',
                  value: weather.current.windKph.toStringAsFixed(1),
                  valueSuffix: 'KM/H ${weather.current.windDir}',
                  caption:
                      'Gusts up to ${weather.current.gustKph.round()} '
                      'km/h.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.wb_sunny_outlined,
                  label: 'UV INDEX',
                  value: weather.current.uv.toStringAsFixed(1),
                  valueSuffix: _uvLabel(weather.current.uv),
                  caption: weather.current.uv >= 3
                      ? 'Use sun protection if outdoors.'
                      : 'Minimal risk right now.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.speed_outlined,
                  label: 'PRESSURE',
                  value: weather.current.pressureMb.round().toString(),
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
                  Row(
                    children: [
                      Expanded(
                        child: DetailItem(
                          label: 'WIND DIRECTION',
                          value:
                              '${weather.current.windDir} '
                              '(${weather.current.windDegree}°)',
                        ),
                      ),
                      Expanded(
                        child: DetailItem(
                          label: 'PRECIPITATION',
                          value: '${weather.current.precipMm} mm',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DetailItem(
                          label: 'CLOUD COVER',
                          value: '${weather.current.cloud}%',
                        ),
                      ),
                      Expanded(
                        child: DetailItem(
                          label: 'RAIN CHANCE',
                          value: '${weather.current.chanceOfRain}%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DetailItem(
                          label: 'HEAT INDEX',
                          value: '${weather.current.heatindexC.round()}°C',
                        ),
                      ),
                      Expanded(
                        child: DetailItem(
                          label: 'WIND CHILL',
                          value: '${weather.current.windchillC.round()}°C',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DetailItem(
                          label: 'VISIBILITY',
                          value: '${weather.current.visKm.round()} km',
                        ),
                      ),
                      Expanded(
                        child: DetailItem(
                          label: 'DEW POINT',
                          value: '${weather.current.dewpointC.round()}°C',
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
    );
  }
}
