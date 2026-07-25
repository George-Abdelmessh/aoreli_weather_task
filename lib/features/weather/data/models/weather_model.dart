class WeatherModel {
  const WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.conditionText,
    required this.conditionIconUrl,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // TODO: map API response (city name, temp, condition text, icon url)
    throw UnimplementedError();
  }

  final String cityName;
  final double temperature;
  final String conditionText;
  final String conditionIconUrl;

  Map<String, dynamic> toJson() {
    // TODO: map fields back to JSON
    throw UnimplementedError();
  }
}
