import 'package:dio/dio.dart';

abstract class BaseApiService {
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<Response> post(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool enableFormData = false,
    Options? options,
  });

  Future<Response> put(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool enableFormData = false,
  });

  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });
}
