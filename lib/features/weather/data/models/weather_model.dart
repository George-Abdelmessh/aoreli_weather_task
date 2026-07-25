import 'package:equatable/equatable.dart';

class WeatherModel extends Equatable {
  const WeatherModel({required this.location, required this.current});

  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel(
    location: WeatherLocation.fromJson(
      json['location'] as Map<String, dynamic>,
    ),
    current: WeatherCurrent.fromJson(json['current'] as Map<String, dynamic>),
  );

  final WeatherLocation location;
  final WeatherCurrent current;

  Map<String, dynamic> toJson() => {
    'location': location.toJson(),
    'current': current.toJson(),
  };

  @override
  List<Object?> get props => [location, current];
}

class WeatherLocation extends Equatable {
  const WeatherLocation({
    required this.name,
    required this.region,
    required this.country,
    required this.localtime,
  });

  factory WeatherLocation.fromJson(Map<String, dynamic> json) =>
      WeatherLocation(
        name: json['name'] as String,
        region: json['region'] as String? ?? '',
        country: json['country'] as String? ?? '',
        localtime: _parseDateTime(json['localtime'] as String),
      );

  final String name;
  final String region;
  final String country;
  final DateTime localtime;

  Map<String, dynamic> toJson() => {
    'name': name,
    'region': region,
    'country': country,
    'localtime': _formatDateTime(localtime),
  };

  @override
  List<Object?> get props => [name, region, country, localtime];
}

class WeatherCurrent extends Equatable {
  const WeatherCurrent({
    required this.lastUpdated,
    required this.tempC,
    required this.feelslikeC,
    required this.condition,
    required this.humidity,
    required this.windKph,
    required this.windDir,
    required this.windDegree,
    required this.gustKph,
    required this.uv,
    required this.pressureMb,
    required this.precipMm,
    required this.cloud,
    required this.heatindexC,
    required this.windchillC,
    required this.visKm,
    required this.dewpointC,
    required this.chanceOfRain,
  });

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) => WeatherCurrent(
    lastUpdated: _parseDateTime(json['last_updated'] as String),
    tempC: (json['temp_c'] as num).toDouble(),
    feelslikeC: (json['feelslike_c'] as num).toDouble(),
    condition: CurrentCondition.fromJson(
      json['condition'] as Map<String, dynamic>,
    ),
    humidity: json['humidity'] as int,
    windKph: (json['wind_kph'] as num).toDouble(),
    windDir: json['wind_dir'] as String,
    windDegree: json['wind_degree'] as int,
    gustKph: (json['gust_kph'] as num).toDouble(),
    uv: (json['uv'] as num).toDouble(),
    pressureMb: (json['pressure_mb'] as num).toDouble(),
    precipMm: (json['precip_mm'] as num).toDouble(),
    cloud: json['cloud'] as int,
    heatindexC: (json['heatindex_c'] as num).toDouble(),
    windchillC: (json['windchill_c'] as num).toDouble(),
    visKm: (json['vis_km'] as num).toDouble(),
    dewpointC: (json['dewpoint_c'] as num).toDouble(),
    chanceOfRain: json['chance_of_rain'] as int,
  );

  final DateTime lastUpdated;
  final double tempC;
  final double feelslikeC;
  final CurrentCondition condition;
  final int humidity;
  final double windKph;
  final String windDir;
  final int windDegree;
  final double gustKph;
  final double uv;
  final double pressureMb;
  final double precipMm;
  final int cloud;
  final double heatindexC;
  final double windchillC;
  final double visKm;
  final double dewpointC;
  final int chanceOfRain;

  Map<String, dynamic> toJson() => {
    'last_updated': _formatDateTime(lastUpdated),
    'temp_c': tempC,
    'feelslike_c': feelslikeC,
    'condition': condition.toJson(),
    'humidity': humidity,
    'wind_kph': windKph,
    'wind_dir': windDir,
    'wind_degree': windDegree,
    'gust_kph': gustKph,
    'uv': uv,
    'pressure_mb': pressureMb,
    'precip_mm': precipMm,
    'cloud': cloud,
    'heatindex_c': heatindexC,
    'windchill_c': windchillC,
    'vis_km': visKm,
    'dewpoint_c': dewpointC,
    'chance_of_rain': chanceOfRain,
  };

  @override
  List<Object?> get props => [
    lastUpdated,
    tempC,
    feelslikeC,
    condition,
    humidity,
    windKph,
    windDir,
    windDegree,
    gustKph,
    uv,
    pressureMb,
    precipMm,
    cloud,
    heatindexC,
    windchillC,
    visKm,
    dewpointC,
    chanceOfRain,
  ];
}

/// Named `CurrentCondition` (not `WeatherCondition`) to avoid clashing with
/// the design-system `WeatherCondition` enum in `app_colors.dart`, which
/// maps this model's [text] to a themed gradient.
class CurrentCondition extends Equatable {
  const CurrentCondition({required this.text, required this.iconUrl});

  factory CurrentCondition.fromJson(Map<String, dynamic> json) {
    final icon = json['icon'] as String;
    return CurrentCondition(
      text: json['text'] as String,
      iconUrl: icon.startsWith('http') ? icon : 'https:$icon',
    );
  }

  final String text;
  final String iconUrl;

  Map<String, dynamic> toJson() => {'text': text, 'icon': iconUrl};

  @override
  List<Object?> get props => [text, iconUrl];
}

/// Parses weatherapi.com's `"yyyy-MM-dd HH:mm"` date strings without
/// pulling in `intl` for a single format.
DateTime _parseDateTime(String raw) {
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

String _formatDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
      '${two(dt.hour)}:${two(dt.minute)}';
}
