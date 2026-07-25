import 'package:equatable/equatable.dart';

class GetWeatherParams extends Equatable {
  const GetWeatherParams({required this.city});

  final String city;

  @override
  List<Object?> get props => [city];
}