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

class RemoteApi implements WeatherRepository {
  RemoteApi({
    required BaseApiService apiService,
    required NetworkInfo networkInfo,
  })  : _apiService = apiService,
        _networkInfo = networkInfo;

  final BaseApiService _apiService;
  final NetworkInfo _networkInfo;

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

      if (response.statusCode == 200) {
        return Right(
          WeatherModel.fromJson(response.data as Map<String, dynamic>),
        );
      }

      return Left(ApiErrorHandler.handleResponse(response));
    } on DioException catch (error) {
      return Left(ApiErrorHandler.handle(error));
    }
  }

  /// The remote datasource has no cache of its own — caching is layered on
  /// top by `WeatherRepositoryImplementation`.
  @override
  WeatherModel? getCachedWeather() => null;

  @override
  List<String> getRecentSearches() => [];
}
