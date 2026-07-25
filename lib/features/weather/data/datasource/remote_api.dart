import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/api/base_api_service.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/connection/network_info.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/constants.dart';
import '../models/weather_model.dart';
import '../params/get_weather_params.dart';
import '../repositories/weather_repository.dart';
import 'local_data.dart';

/// The `WeatherRepository` implementation. Fetches weather from the API
/// and, on success, hands it to `LocalData` to cache and add to recent
/// searches. Cache reads (`getCachedWeather`/`getRecentSearches`) are
/// delegated straight through to `LocalData`.
class RemoteApi implements WeatherRepository {
  RemoteApi({
    required BaseApiService apiService,
    required NetworkInfo networkInfo,
    required LocalData localData,
  }) : _apiService = apiService,
       _networkInfo = networkInfo,
       _localData = localData;

  final BaseApiService _apiService;
  final NetworkInfo _networkInfo;
  final LocalData _localData;

  @override
  Future<Either<Failure, WeatherModel>> getWeather(
    GetWeatherParams params,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NoInternetFailure());
    }

    try {
      final response = await _apiService.get(
        EndPoints.CURRENT_WEATHER,
        queryParameters: {
          'key': dotenv.env[EnvKeys.weatherApiKey],
          'q': params.city,
          'aqi': 'no',
        },
      );

      if (response.statusCode != 200) {
        return Left(ApiErrorHandler.handleResponse(response));
      }

      final weather = WeatherModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _localData.saveWeather(weather);
      return Right(weather);
    } on DioException catch (error) {
      return Left(ApiErrorHandler.handle(error));
    }
  }

  @override
  WeatherModel? getCachedWeather() => _localData.getCachedWeather();

  @override
  List<String> getRecentSearches() => _localData.getRecentSearches();
}
