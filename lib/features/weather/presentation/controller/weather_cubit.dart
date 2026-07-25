import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../data/params/get_weather_params.dart';
import '../../data/repositories/weather_repository.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({required WeatherRepository weatherRepository})
      : _weatherRepository = weatherRepository,
        super(const WeatherState.initial());

  final WeatherRepository _weatherRepository;

  /// The last searched locations (most recent first), for quick re-search
  /// shortcuts on the Home screen.
  List<String> getRecentSearches() => _weatherRepository.getRecentSearches();

  Future<void> fetchWeather(String city) async {
    emit(const WeatherState.loading());
    final result = await _weatherRepository.getWeather(
      GetWeatherParams(city: city),
    );
    result.fold(
      (failure) {
        if (failure is NoInternetFailure) {
          final cached = _weatherRepository.getCachedWeather();
          if (cached != null) {
            emit(WeatherState.success(cached, isCached: true));
            return;
          }
        }
        emit(WeatherState.error(failure.message));
      },
      (weather) => emit(WeatherState.success(weather)),
    );
  }
}
