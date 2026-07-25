part of 'weather_cubit.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

class WeatherSuccess extends WeatherState {
  const WeatherSuccess();

  @override
  List<Object?> get props => [];
}

class WeatherError extends WeatherState {
  const WeatherError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class WeatherUnitToggled extends WeatherState {
  const WeatherUnitToggled();
}
