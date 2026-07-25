import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/cache/shared_preferences_service.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/constants.dart';
import '../models/weather_model.dart';
import '../params/get_weather_params.dart';
import '../repositories/weather_repository.dart';

/// Adds offline caching on top of the existing remote fetch logic — the
/// remote datasource ([WeatherRepository] `remoteApi`) is left untouched;
/// this class only decides when to save/read the cache around it.
class WeatherRepositoryImplementation implements WeatherRepository {
  WeatherRepositoryImplementation({
    required WeatherRepository remoteApi,
    required SharedPreferencesService sharedPreferencesService,
  })  : _remoteApi = remoteApi,
        _sharedPreferencesService = sharedPreferencesService;

  final WeatherRepository _remoteApi;
  final SharedPreferencesService _sharedPreferencesService;

  @override
  Future<Either<Failure, WeatherModel>> getWeather(
    GetWeatherParams params,
  ) async {
    final result = await _remoteApi.getWeather(params);

    result.fold((failure) {}, (weatherModel) {
      _sharedPreferencesService.saveData(
        key: Constants.kCachedWeather,
        value: jsonEncode(weatherModel.toJson()),
      );
      _saveRecentSearch(weatherModel);
    });

    return result;
  }

  @override
  WeatherModel? getCachedWeather() {
    try {
      final raw = _sharedPreferencesService.getData(
        key: Constants.kCachedWeather,
      );
      if (raw == null) {
        return null;
      }
      return WeatherModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<String> getRecentSearches() {
    try {
      final raw = _sharedPreferencesService.getData(
        key: Constants.kRecentSearches,
      );
      if (raw == null) {
        return [];
      }
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }

  void _saveRecentSearch(WeatherModel weatherModel) {
    final label = [
      weatherModel.cityName,
      weatherModel.country,
    ].where((s) => s.isNotEmpty).join(', ');

    final recent = getRecentSearches()
      ..removeWhere((existing) => existing.toLowerCase() == label.toLowerCase())
      ..insert(0, label);

    _sharedPreferencesService.saveData(
      key: Constants.kRecentSearches,
      value: jsonEncode(recent.take(Constants.kMaxRecentSearches).toList()),
    );
  }
}
