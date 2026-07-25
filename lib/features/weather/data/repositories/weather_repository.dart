import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../models/weather_model.dart';
import '../params/get_weather_params.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherModel>> getWeather(GetWeatherParams params);

  /// Returns the last successfully cached [WeatherModel], or `null` if
  /// nothing has been cached yet (or the cached value is unreadable).
  WeatherModel? getCachedWeather();

  /// The last searched locations (most recent first, as "City, Country"
  /// labels), capped at `Constants.kMaxRecentSearches`.
  List<String> getRecentSearches();
}
