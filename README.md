# Aoreli Weather

A Flutter weather app that lets you search any city and get its current
conditions — temperature, feels-like, humidity, wind, UV index, pressure,
and more — with recent searches and offline caching built in.

## Features

- **City search** with a persistent list of recent searches (most recent
  first), stored on-device.
- **Current conditions** view: temperature (°C/°F toggle), feels-like,
  condition icon/text, humidity, wind speed/direction/gusts, UV index,
  pressure, precipitation, cloud cover, chance of rain, heat index, wind
  chill, visibility, and dew point.
- **Offline support** — the last successfully fetched forecast is cached
  locally; if a new search fails because there's no internet connection,
  the app falls back to the cached result and shows an offline banner.
- **Animated splash screen** leading into the search screen.

## Tech Stack

- [Flutter](https://flutter.dev) / Dart
- **State management:** `flutter_bloc` (Cubit)
- **DI:** `get_it`
- **Networking:** `dio` (+ `pretty_dio_logger` in debug builds), data
  sourced from [WeatherAPI](https://www.weatherapi.com/)
- **Local storage:** `shared_preferences`
- **Connectivity checks:** `connectivity_plus`
- **Functional error handling:** `dartz` (`Either<Failure, T>`)
- **Env config:** `flutter_dotenv`
- Other UI packages: `google_fonts`, `flutter_svg`, `cached_network_image`,
  `skeletonizer`

## Architecture

The project follows a feature-first structure with a light Clean
Architecture split between data and presentation layers:

```
lib/
├── core/                 # Shared building blocks
│   ├── api/              # Dio wrapper, base API contract, endpoints
│   ├── cache/            # SharedPreferences wrapper
│   ├── config/themes/    # Colors, paddings, app theme
│   ├── connection/       # Network connectivity check
│   ├── di/               # get_it service locator
│   ├── error/            # Failure types + API error handler
│   ├── helpers/          # Navigation, validators, misc helpers
│   └── utils/            # Constants, asset paths, screen scaling
├── features/
│   ├── shared/           # Reusable widgets (buttons, inputs)
│   ├── splash/           # Splash screen
│   └── weather/
│       ├── data/
│       │   ├── datasource/    # RemoteApi (network) & LocalData (cache)
│       │   ├── models/        # WeatherModel and JSON mapping
│       │   ├── params/        # GetWeatherParams
│       │   └── repositories/  # WeatherRepository contract
│       └── presentation/
│           ├── controller/    # WeatherCubit / WeatherState
│           └── view/           # Search & Result screens + widgets
└── main.dart
```

`WeatherCubit` calls into `WeatherRepository`, implemented by `RemoteApi`,
which checks connectivity, hits the WeatherAPI `current.json` endpoint via
`DioApiService`, and delegates persistence (caching + recent searches) to
`LocalData`. On failure with no internet, the cubit falls back to the
last cached `WeatherModel` if one exists.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK
  `^3.12.2`, see `pubspec.yaml`)
- A free API key from [WeatherAPI](https://www.weatherapi.com/)

### Setup

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Create a `.env` file in the project root with your API credentials:

   ```env
   WEATHER_API_KEY=your_weatherapi_key_here
   WEATHER_BASE_URL=https://api.weatherapi.com/v1
   ```

   This file is declared as a Flutter asset in `pubspec.yaml` and loaded at
   startup via `flutter_dotenv`, so the app won't run without it.

3. Run the app:

   ```bash
   flutter run
   ```

### Running Tests

```bash
flutter test
```

## Project Info

- Package name: `aoreli_weather`
- Version: `1.0.0+1`
