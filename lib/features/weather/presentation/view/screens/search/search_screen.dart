import 'package:aoreli_weather/core/helpers/app_validators.dart';
import 'package:aoreli_weather/core/utils/screen_size.dart';
import 'package:aoreli_weather/features/shared/custom_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../core/config/themes/app_colors.dart';
import '../../../../../../core/config/themes/app_padding.dart';
import '../../../../../../core/helpers/app_navigator.dart';
import '../../../../../../core/utils/asset_paths.dart';
import '../../../../../shared/custom_widgets/cutom_input.dart';
import '../../../../data/params/get_weather_params.dart';
import '../../../controller/weather_cubit.dart';
import '../result/result_screen.dart';
import 'widgets/recent_search_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late List<String> _recentSearches;

  @override
  void initState() {
    super.initState();
    _updateRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  void _search(String city) {
    if (city.isEmpty) {
      _formKey.currentState!.validate();
      return;
    }
    _searchController.text = city.trim();
    context
        .read<WeatherCubit>()
        .fetchWeather(GetWeatherParams(city: city.trim()))
        .then((value) {
          _updateRecentSearches();
        });
    AppNavigator.push(
      context: context,
      screen: ResultScreen(city: city.trim()),
    );
  }

  void _updateRecentSearches() {
    _recentSearches = context.read<WeatherCubit>().getRecentSearches();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                CutsomButton(
                  onPressed: () => _search(_searchController.text),
                  backgroundColor: AppColors.primary,
                  child: Text(
                    'Search',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.surface,
                      fontSize: ScreenSize.fontScale(context, 16),
                    ),
                  ),
                ),
                if (_recentSearches.isNotEmpty) ...[
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

                  BlocBuilder<WeatherCubit, WeatherState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          for (final label in _recentSearches) ...[
                            RecentSearchTile(
                              label: label,
                              onTap: () => _search(_cityFromLabel(label)),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  
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
