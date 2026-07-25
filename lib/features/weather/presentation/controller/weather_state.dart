import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/weather_model.dart';

part 'weather_state.freezed.dart';

@freezed
class WeatherState with _$WeatherState {
  const factory WeatherState.initial() = _Initial;
  const factory WeatherState.loading() = _Loading;
  const factory WeatherState.success(WeatherModel weather) = _Success;
  const factory WeatherState.error(String message) = _Error;
}
