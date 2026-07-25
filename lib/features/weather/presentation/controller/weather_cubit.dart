import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/weather_repository.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({required WeatherRepository weatherRepository})
      : _weatherRepository = weatherRepository,
        super(const WeatherState.initial());

  final WeatherRepository _weatherRepository;

  Future<void> fetchWeather(String city) async {
    // TODO: emit loading, call _weatherRepository.getWeather, emit
    // success/error based on the Either result.
  }
}
