import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../core/helpers/app_navigator.dart';
import '../../../../../../core/helpers/location_service.dart';
import '../../../../../../core/helpers/permission_service.dart';
import '../../../../data/models/weather_model.dart';
import '../../../../data/params/get_weather_params.dart';
import '../../../controller/weather_cubit.dart';
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
    context.read<WeatherCubit>().fetchWeather(GetWeatherParams(city: trimmed));
  }

  void _toggleUnit() {
    setState(() => _isFahrenheit = !_isFahrenheit);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        final gradient = switch (state) {
          WeatherLoading() => AppColors.loadingGradient,
          WeatherSuccess(weather: final weather) =>
            AppColors.backgroundGradient(
              WeatherCondition.fromApiText(weather.current.condition.text),
            ),
          WeatherError() => AppColors.errorGradient,
          // WeatherInitial, plus a defensive fallback for any future state
          // (WeatherState is a plain abstract class, not `sealed`, so the
          // compiler can't prove this switch is exhaustive).
          _ => AppColors.splashGradient,
        };

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
              child: switch (state) {
                WeatherLoading() => _LoadingContent(
                  controller: _searchController,
                  onSearch: _search,
                ),
                WeatherSuccess(
                  weather: final weather,
                  isCached: final isCached,
                ) =>
                  _WeatherResultContent(
                    weather: weather,
                    isCached: isCached,
                    controller: _searchController,
                    onSearch: _search,
                    isFahrenheit: _isFahrenheit,
                    onToggleUnit: _toggleUnit,
                  ),
                WeatherError(message: final message) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _ErrorContent(
                    message: message,
                    controller: _searchController,
                    onSearch: _search,
                  ),
                ),
                // WeatherInitial, plus a defensive fallback for any future
                // state (WeatherState is a plain abstract class, not
                // `sealed`, so this switch can't be exhaustiveness-checked).
                _ => _HomeContent(
                  controller: _searchController,
                  onSearch: _search,
                  recentSearches: context
                      .read<WeatherCubit>()
                      .getRecentSearches(),
                ),
              },
            ),
          ),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.controller,
    required this.onSearch,
    this.recentSearches = const [],
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final List<String> recentSearches;

  /// A recent-search label is stored as "City, Country" — re-search using
  /// just the city part.
  static String _cityFromLabel(String label) => label.split(',').first.trim();

  Future<void> _useMyLocation(BuildContext context) async {
    final serviceEnabled = await AppLocationService.isServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) {
        return;
      }
      _showLocationRequiredDialog(
        context,
        message: 'Turn on location services on your device to use this.',
      );
      return;
    }

    final granted = await AppPermissionService.requestLocationPermission();
    if (!granted) {
      if (!context.mounted) {
        return;
      }
      _showLocationRequiredDialog(
        context,
        message:
            'Aoreli needs location access to show weather for where '
            "you are. You'll need to grant it from Settings.",
      );
      return;
    }

    try {
      final position = await AppLocationService.getCurrentPosition();
      onSearch('${position.latitude},${position.longitude}');
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't get your location. Please try again."),
        ),
      );
    }
  }

  void _showLocationRequiredDialog(
    BuildContext context, {
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Location access required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(context: dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              AppNavigator.pop(context: dialogContext);
              AppPermissionService.openSettings();
            },
            child: const Text('Give Access'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          children: [
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
            const SizedBox(height: 40),
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
            const SizedBox(height: 40),
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
                onPressed: () => _useMyLocation(context),
                icon: const Icon(Icons.near_me_outlined, size: 18),
                label: const Text('Use my location'),
              ),
            ),
            if (recentSearches.isNotEmpty) ...[
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'RECENT SEARCHES',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final label in recentSearches) ...[
                _RecentSearchTile(
                  label: label,
                  onTap: () => onSearch(_cityFromLabel(label)),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentSearchTile extends StatelessWidget {
  const _RecentSearchTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.history, size: 18, color: AppColors.outline),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ),
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
  const _LoadingContent({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final city = controller.text.trim();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CompactHeader(),
            const SizedBox(height: 16),
            WeatherSearchField(controller: controller, onSubmitted: onSearch),
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
            const _ResultSkeleton(),
          ],
        ),
      ),
    );
  }
}

/// Shimmering placeholder that mirrors [_WeatherResultContent]'s layout, so
/// the loading state previews the shape of the data about to arrive.
class _ResultSkeleton extends StatelessWidget {
  const _ResultSkeleton();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cairo, Al Qahirah, Egypt',
            style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            'WEDNESDAY, 22 JULY 2026',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.outline,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '41°',
            style: textTheme.displayMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 24),
              const SizedBox(width: 6),
              Text(
                'Sunny',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.water_drop_outlined,
                  label: 'HUMIDITY',
                  value: '44%',
                  caption: 'The dew point is 9° right now.',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.air,
                  label: 'WIND',
                  value: '34.6',
                  valueSuffix: 'KM/H NW',
                  caption: 'Gusts up to 41 km/h.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.wb_sunny_outlined,
                  label: 'UV INDEX',
                  value: '0.2',
                  valueSuffix: 'LOW',
                  caption: 'Minimal risk right now.',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.speed_outlined,
                  label: 'PRESSURE',
                  value: '1007',
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
                  const Row(
                    children: [
                      Expanded(
                        child: _DetailItem(
                          label: 'WIND DIRECTION',
                          value: 'NW (318°)',
                        ),
                      ),
                      Expanded(
                        child: _DetailItem(
                          label: 'PRECIPITATION',
                          value: '0 mm',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: _DetailItem(label: 'CLOUD COVER', value: '0%'),
                      ),
                      Expanded(
                        child: _DetailItem(label: 'RAIN CHANCE', value: '1%'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: _DetailItem(label: 'HEAT INDEX', value: '39°C'),
                      ),
                      Expanded(
                        child: _DetailItem(label: 'WIND CHILL', value: '39°C'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: _DetailItem(label: 'VISIBILITY', value: '10 km'),
                      ),
                      Expanded(
                        child: _DetailItem(label: 'DEW POINT', value: '9°C'),
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
                _UnitToggle(isFahrenheit: isFahrenheit, onToggle: onToggleUnit),
              ],
            ),
            const SizedBox(height: 16),
            WeatherSearchField(controller: controller, onSubmitted: onSearch),
            if (isCached) ...[
              const SizedBox(height: 12),
              const _OfflineCacheBanner(),
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
                  child: _StatCard(
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
                  child: _StatCard(
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
                  child: _StatCard(
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
                  child: _StatCard(
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
                                '${weather.current.windDir} '
                                '(${weather.current.windDegree}°)',
                          ),
                        ),
                        Expanded(
                          child: _DetailItem(
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
                          child: _DetailItem(
                            label: 'CLOUD COVER',
                            value: '${weather.current.cloud}%',
                          ),
                        ),
                        Expanded(
                          child: _DetailItem(
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
                          child: _DetailItem(
                            label: 'HEAT INDEX',
                            value: '${weather.current.heatindexC.round()}°C',
                          ),
                        ),
                        Expanded(
                          child: _DetailItem(
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
                          child: _DetailItem(
                            label: 'VISIBILITY',
                            value: '${weather.current.visKm.round()} km',
                          ),
                        ),
                        Expanded(
                          child: _DetailItem(
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
                style: textTheme.labelSmall?.copyWith(color: AppColors.outline),
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

/// Shown above the weather card when the displayed data came from the
/// offline cache instead of a fresh API response.
class _OfflineCacheBanner extends StatelessWidget {
  const _OfflineCacheBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.onTertiaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 16,
              color: AppColors.onTertiaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Showing last saved result — you're offline",
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
