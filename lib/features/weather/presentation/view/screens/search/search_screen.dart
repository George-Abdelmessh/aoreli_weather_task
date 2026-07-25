import 'package:aoreli_weather/core/helpers/AppValidators.dart';
import 'package:aoreli_weather/core/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../core/config/themes/app_padding.dart';
import '../../../../../../core/helpers/app_navigator.dart';
import '../../../../../../core/helpers/location_service.dart';
import '../../../../../../core/helpers/permission_service.dart';
import '../../../../../../core/utils/asset_paths.dart';
import '../../../../data/params/get_weather_params.dart';
import '../../../controller/weather_cubit.dart';
import '../../../../../shared/custom_widgets/cutom_input.dart';
import '../result/result_screen.dart';
import 'widgets/recent_search_tile.dart';

/// Entry screen: search for a city, use the current location, or re-run a
/// recent search. On submit it kicks off [WeatherCubit.fetchWeather] and
/// pushes [ResultScreen], which owns the loading/success UI.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String city) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final trimmed = city.trim();
    if (trimmed.isEmpty) {
      return;
    }
    context.read<WeatherCubit>().fetchWeather(GetWeatherParams(city: trimmed));
    AppNavigator.push(
      context: context,
      screen: ResultScreen(city: trimmed),
    );
  }

  Future<void> _useMyLocation() async {
    final serviceEnabled = await AppLocationService.isServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) {
        return;
      }
      _showLocationRequiredDialog(
        message: 'Turn on location services on your device to use this.',
      );
      return;
    }

    final granted = await AppPermissionService.requestLocationPermission();
    if (!granted) {
      if (!mounted) {
        return;
      }
      _showLocationRequiredDialog(
        message:
            'Aoreli needs location access to show weather for where '
            "you are. You'll need to grant it from Settings.",
      );
      return;
    }

    try {
      final position = await AppLocationService.getCurrentPosition();
      _search('${position.latitude},${position.longitude}');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't get your location. Please try again."),
        ),
      );
    }
  }

  void _showLocationRequiredDialog({required String message}) {
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
    final recentSearches = context.read<WeatherCubit>().getRecentSearches();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.splashGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppPadding.screenBodyNoHeader,
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
                SvgPicture.asset(
                  AssetPaths.sunIcon,
                  width: ScreenSize.widthScale(context, 110),
                  height: ScreenSize.heightScale(context, 110),
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
                    'Location',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Form(
                  key: _formKey,
                  child: CustomInput(
                    controller: _searchController,
                    onSubmitted: _search,
                    hintText: 'Search for a city',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                    ),
                    validator: (value) => value?.required(),
                  ),
                ),
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
                    onPressed: () => _search(_searchController.text),

                    child: const Text('View weather'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _useMyLocation,
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
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final label in recentSearches) ...[
                    RecentSearchTile(
                      label: label,
                      onTap: () => _search(_cityFromLabel(label)),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A recent-search label is stored as "City, Country" — re-search using
  /// just the city part.
  static String _cityFromLabel(String label) => label.split(',').first.trim();
}
