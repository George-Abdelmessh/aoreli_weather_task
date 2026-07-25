import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../models/weather_model.dart';
import '../params/get_weather_params.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherModel>> getWeather(GetWeatherParams params);
}
