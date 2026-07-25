class WeatherModel {
  const WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.conditionText,
    required this.conditionIconUrl,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final condition = current['condition'] as Map<String, dynamic>;
    final iconPath = condition['icon'] as String;

    return WeatherModel(
      cityName: location['name'] as String,
      temperature: (current['temp_c'] as num).toDouble(),
      conditionText: condition['text'] as String,
      conditionIconUrl:
          iconPath.startsWith('http') ? iconPath : 'https:$iconPath',
    );
  }

  final String cityName;
  final double temperature;
  final String conditionText;
  final String conditionIconUrl;

  Map<String, dynamic> toJson() {
    return {
      'location': {'name': cityName},
      'current': {
        'temp_c': temperature,
        'condition': {'text': conditionText, 'icon': conditionIconUrl},
      },
    };
  }
}
