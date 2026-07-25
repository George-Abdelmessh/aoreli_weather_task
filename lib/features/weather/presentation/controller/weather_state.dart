import 'package:equatable/equatable.dart';

import '../../data/models/weather_model.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();

  const factory WeatherState.initial() = WeatherInitial;
  const factory WeatherState.loading() = WeatherLoading;
  const factory WeatherState.success(
    WeatherModel weather, {
    bool isCached,
  }) = WeatherSuccess;
  const factory WeatherState.error(String message) = WeatherError;

  /// Pattern-matches over the possible states, similar to a `switch`
  /// expression, so call sites can handle each case explicitly.
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(WeatherModel weather, bool isCached) success,
    required T Function(String message) error,
  }) {
    final state = this;
    return switch (state) {
      WeatherInitial() => initial(),
      WeatherLoading() => loading(),
      WeatherSuccess(:final weather, :final isCached) => success(
        weather,
        isCached,
      ),
      WeatherError(:final message) => error(message),
    };
  }
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();

  @override
  List<Object?> get props => [];
}

class WeatherLoading extends WeatherState {
  const WeatherLoading();

  @override
  List<Object?> get props => [];
}

class WeatherSuccess extends WeatherState {
  const WeatherSuccess(this.weather, {this.isCached = false});

  final WeatherModel weather;
  final bool isCached;

  @override
  List<Object?> get props => [weather, isCached];
}

class WeatherError extends WeatherState {
  const WeatherError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
