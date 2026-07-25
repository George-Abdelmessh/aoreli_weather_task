class EndPoints {
  EndPoints._();

  static const String WEATHER_BASE_URL = 'https://api.weatherapi.com/v1';

  static String getWeather({required String city}) {
    // TODO: append API key and query parameters as required by weatherapi.com
    return '$WEATHER_BASE_URL/current.json?q=$city';
  }
}
