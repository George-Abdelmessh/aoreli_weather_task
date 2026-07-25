import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'base_api_service.dart';
import 'end_points.dart';

class DioApiService implements BaseApiService {
  DioApiService({required Dio dioClient}) : _dio = dioClient {
    _dio.options = BaseOptions(
      baseUrl: EndPoints.WEATHER_BASE_URL,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: false,
      receiveDataWhenStatusError: true,
      validateStatus: (status) => status != null && status < 999,
    );

    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger());
    }
  }

  final Dio _dio;

  @override
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response> post(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool enableFormData = false,
    Options? options,
  }) {
    return _dio.post(
      endpoint,
      queryParameters: queryParameters,
      data: enableFormData
          ? FormData.fromMap(body as Map<String, dynamic>)
          : body,
      options: options,
    );
  }

  @override
  Future<Response> put(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool enableFormData = false,
  }) {
    return _dio.put(
      endpoint,
      queryParameters: queryParameters,
      data: enableFormData
          ? FormData.fromMap(body as Map<String, dynamic>)
          : body,
    );
  }

  @override
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete(endpoint, queryParameters: queryParameters);
  }
}
