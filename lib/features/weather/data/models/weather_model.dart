class WeatherModel {
  const WeatherModel({
    required this.cityName,
    required this.region,
    required this.country,
    required this.localTime,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.conditionText,
    required this.conditionIconUrl,
    required this.lastUpdated,
    required this.humidity,
    required this.windKph,
    required this.windDir,
    required this.windDegree,
    required this.gustKph,
    required this.uv,
    required this.pressureMb,
    required this.precipMm,
    required this.cloud,
    required this.heatIndexC,
    required this.windChillC,
    required this.visKm,
    required this.dewPointC,
    required this.chanceOfRain,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final condition = current['condition'] as Map<String, dynamic>;
    final iconPath = condition['icon'] as String;

    return WeatherModel(
      cityName: location['name'] as String,
      region: location['region'] as String? ?? '',
      country: location['country'] as String? ?? '',
      localTime: _parseDateTime(location['localtime'] as String),
      temperatureC: (current['temp_c'] as num).toDouble(),
      feelsLikeC: (current['feelslike_c'] as num).toDouble(),
      conditionText: condition['text'] as String,
      conditionIconUrl:
          iconPath.startsWith('http') ? iconPath : 'https:$iconPath',
      lastUpdated: _parseDateTime(current['last_updated'] as String),
      humidity: current['humidity'] as int,
      windKph: (current['wind_kph'] as num).toDouble(),
      windDir: current['wind_dir'] as String,
      windDegree: current['wind_degree'] as int,
      gustKph: (current['gust_kph'] as num).toDouble(),
      uv: (current['uv'] as num).toDouble(),
      pressureMb: (current['pressure_mb'] as num).toDouble(),
      precipMm: (current['precip_mm'] as num).toDouble(),
      cloud: current['cloud'] as int,
      heatIndexC: (current['heatindex_c'] as num).toDouble(),
      windChillC: (current['windchill_c'] as num).toDouble(),
      visKm: (current['vis_km'] as num).toDouble(),
      dewPointC: (current['dewpoint_c'] as num).toDouble(),
      chanceOfRain: current['chance_of_rain'] as int,
    );
  }

  final String cityName;
  final String region;
  final String country;
  final DateTime localTime;
  final double temperatureC;
  final double feelsLikeC;
  final String conditionText;
  final String conditionIconUrl;
  final DateTime lastUpdated;
  final int humidity;
  final double windKph;
  final String windDir;
  final int windDegree;
  final double gustKph;
  final double uv;
  final double pressureMb;
  final double precipMm;
  final int cloud;
  final double heatIndexC;
  final double windChillC;
  final double visKm;
  final double dewPointC;
  final int chanceOfRain;

  Map<String, dynamic> toJson() {
    return {
      'location': {
        'name': cityName,
        'region': region,
        'country': country,
        'localtime': _formatDateTime(localTime),
      },
      'current': {
        'last_updated': _formatDateTime(lastUpdated),
        'temp_c': temperatureC,
        'feelslike_c': feelsLikeC,
        'condition': {'text': conditionText, 'icon': conditionIconUrl},
        'humidity': humidity,
        'wind_kph': windKph,
        'wind_dir': windDir,
        'wind_degree': windDegree,
        'gust_kph': gustKph,
        'pressure_mb': pressureMb,
        'precip_mm': precipMm,
        'cloud': cloud,
        'heatindex_c': heatIndexC,
        'windchill_c': windChillC,
        'vis_km': visKm,
        'dewpoint_c': dewPointC,
        'uv': uv,
        'chance_of_rain': chanceOfRain,
      },
    };
  }

  /// Parses weatherapi.com's `"yyyy-MM-dd HH:mm"` date strings without
  /// pulling in `intl` for a single format.
  static DateTime _parseDateTime(String raw) {
    final parts = raw.split(' ');
    final dateParts = parts[0].split('-').map(int.parse).toList();
    final timeParts = parts[1].split(':').map(int.parse).toList();
    return DateTime(
      dateParts[0],
      dateParts[1],
      dateParts[2],
      timeParts[0],
      timeParts[1],
    );
  }

  static String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }
}
