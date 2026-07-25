import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/weather/data/datasource/local_data.dart';
import '../../features/weather/data/datasource/remote_api.dart';
import '../../features/weather/data/repositories/weather_repository.dart';
import '../../features/weather/presentation/controller/weather_cubit.dart';
import '../api/base_api_service.dart';
import '../api/dio_api_service.dart';
import '../cache/shared_preferences_service.dart';
import '../connection/network_info.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  sl
    //! Features (repository, then implementation, per feature)
    ..registerFactory<WeatherCubit>(() => WeatherCubit(sl()))
    ..registerLazySingleton<WeatherRepository>(
      () => RemoteApi(apiService: sl(), networkInfo: sl(), localData: sl()),
    )
    ..registerLazySingleton<LocalData>(
      () => LocalData(sharedPreferencesService: sl()),
    )
    //! Core
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
    ..registerLazySingleton<BaseApiService>(
      () => DioApiService(dioClient: sl<Dio>()),
    )
    ..registerLazySingleton<SharedPreferencesService>(
      () => SharedPreferencesService(sl()),
    )
    //! External
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<Dio>(Dio.new)
    ..registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}
