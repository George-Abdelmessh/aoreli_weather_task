import 'package:dartz/dartz.dart';

import '../../../../core/api/base_api_service.dart';
import '../../../../core/connection/network_info.dart';
import '../../../../core/error/failure.dart';
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
    // TODO: check _networkInfo.isConnected, call API via _apiService,
    // parse response into WeatherModel, map errors via ApiErrorHandler.
    throw UnimplementedError();
  }
}
