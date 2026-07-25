import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/params/get_weather_params.dart';
import '../../data/repositories/weather_repository.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({required WeatherRepository weatherRepository})
      : _weatherRepository = weatherRepository,
        super(const WeatherState.initial());

  final WeatherRepository _weatherRepository;

  Future<void> fetchWeather(String city) async {
    emit(const WeatherState.loading());
    final result = await _weatherRepository.getWeather(
      GetWeatherParams(city: city),
    );
    result.fold(
      (failure) => emit(WeatherState.error(failure.message)),
      (weather) => emit(WeatherState.success(weather)),
    );
  }
}
