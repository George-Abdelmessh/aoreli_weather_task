import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/weather/data/datasource/remote_api.dart';
import '../../features/weather/data/repositories/weather_repository.dart';
import '../api/base_api_service.dart';
import '../api/dio_api_service.dart';
import '../connection/network_info.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  sl
    //! Features (repository, then implementation, per feature)
    ..registerLazySingleton<WeatherRepository>(
      () => RemoteApi(
        apiService: sl(),
        networkInfo: sl(),
      ),
    )
    //! Core
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
    ..registerLazySingleton<BaseApiService>(
      () => DioApiService(dioClient: sl<Dio>()),
    )
    //! External
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<Dio>(Dio.new);

  // TODO: register SharedPreferencesService once available, per CLAUDE.md order
  await SharedPreferences.getInstance();
}
