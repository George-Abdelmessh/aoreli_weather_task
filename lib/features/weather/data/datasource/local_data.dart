import 'dart:convert';

import '../../../../core/cache/shared_preferences_service.dart';
import '../../../../core/utils/constants.dart';
import '../models/weather_model.dart';

/// Owns everything about the weather feature's on-device persistence: the
/// last-fetched weather cache and the recent-searches list. It has no
/// notion of the network; `RemoteApi` (the `WeatherRepository`
/// implementation) calls into this after a successful fetch.
class LocalData {
  LocalData({required SharedPreferencesService sharedPreferencesService})
    : _sharedPreferencesService = sharedPreferencesService;

  final SharedPreferencesService _sharedPreferencesService;

  /// Persists [weather] as the latest cache and pushes it to the top of the
  /// recent-searches list, called after a successful remote fetch.
  Future<void> saveWeather(WeatherModel weather) async {
    await _sharedPreferencesService.saveData(
      key: Constants.kCachedWeather,
      value: jsonEncode(weather.toJson()),
    );
    await _saveRecentSearch(weather);
  }

  /// Returns the last successfully cached [WeatherModel], or `null` if
  /// nothing has been cached yet (or the cached value is unreadable).
  WeatherModel? getCachedWeather() {
    try {
      final raw = _sharedPreferencesService.getData(
        key: Constants.kCachedWeather,
      );
      if (raw == null) {
        return null;
      }
      return WeatherModel.fromJson(
        jsonDecode(raw as String) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  /// The last searched locations (most recent first, as "City, Country"
  /// labels), capped at `Constants.kMaxRecentSearches`.
  List<String> getRecentSearches() {
    try {
      final raw = _sharedPreferencesService.getData(
        key: Constants.kRecentSearches,
      );
      if (raw == null) {
        return [];
      }
      return List<String>.from(jsonDecode(raw as String) as List);
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveRecentSearch(WeatherModel weather) async {
    final label = _recentSearchLabel(weather);

    final recent = getRecentSearches()
      ..removeWhere((existing) => existing.toLowerCase() == label.toLowerCase())
      ..insert(0, label);

    await _sharedPreferencesService.saveData(
      key: Constants.kRecentSearches,
      value: jsonEncode(recent.take(Constants.kMaxRecentSearches).toList()),
    );
  }

  String _recentSearchLabel(WeatherModel weather) {
    return [
      weather.location.name,
      weather.location.country,
    ].where((s) => s.isNotEmpty).join(', ');
  }
}
