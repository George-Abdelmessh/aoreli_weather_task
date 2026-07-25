import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'base_api_service.dart';

class DioApiService implements BaseApiService {
  DioApiService({required Dio dioClient}) : _dio = dioClient {
    // TODO: configure BaseOptions (baseUrl, timeouts, validateStatus, etc.)
    // TODO: add CustomInterceptor and PrettyDioLogger (if kDebugMode)
  }

  final Dio _dio;

  @override
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<Response> post(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool enableFormData = false,
    Options? options,
  }) {
    // TODO: implement post
    throw UnimplementedError();
  }

  @override
  Future<Response> put(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool enableFormData = false,
  }) {
    // TODO: implement put
    throw UnimplementedError();
  }

  @override
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    // TODO: implement delete
    throw UnimplementedError();
  }
}
