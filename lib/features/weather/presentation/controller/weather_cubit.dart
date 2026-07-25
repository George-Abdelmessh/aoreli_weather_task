import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../data/models/weather_model.dart';
import '../../data/params/get_weather_params.dart';
import '../../data/repositories/weather_repository.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(const WeatherInitial());

  static WeatherCubit get(BuildContext context) => BlocProvider.of(context);

  final WeatherRepository _weatherRepository;
  bool isFahrenheit = false;
  WeatherModel? weather;
  bool isCached = false;

  /// The last searched locations (most recent first), for quick re-search
  /// shortcuts on the Home screen.
  List<String> getRecentSearches() => _weatherRepository.getRecentSearches();

  /// Fetches weather data for a given city.
  Future<void> fetchWeather(GetWeatherParams params) async {
    emit(const WeatherLoading());
    final result = await _weatherRepository.getWeather(params);
    result.fold((failure) {
      if (failure is NoInternetFailure) {
        final cached = _weatherRepository.getCachedWeather();
        if (cached != null) {
          emit(const WeatherSuccess());
          isCached = true;
          return;
        }
      }
      emit(WeatherError(failure.message));
    }, (data) {
      weather = data;
      isCached = false;
      emit(const WeatherSuccess());
    });
  }

  void toggleUnit() {
    isFahrenheit = !isFahrenheit;
    emit(const WeatherUnitToggled());
  }
}
