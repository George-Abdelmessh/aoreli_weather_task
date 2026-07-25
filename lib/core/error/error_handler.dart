import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'failure.dart';

/// Canonical API error handler.
class ApiErrorHandler {
  ApiErrorHandler._();

  static final Logger _logger = Logger('ApiErrorHandler');

  /// weatherapi.com's error code for a city that couldn't be resolved.
  static const int _cityNotFoundCode = 1006;

  static const Map<int, String> _statusCodeMessages = {
    400: 'failure.bad_request',
    401: 'failure.unauthorized',
    403: 'failure.forbidden',
    404: 'failure.not_found',
    405: 'failure.method_not_allowed',
    409: 'failure.conflict',
    422: 'failure.validation',
    429: 'failure.rate_limit',
    500: 'failure.server_error',
    502: 'failure.server_error',
    503: 'failure.server_error',
  };

  static Failure handle(DioException error) {
    _logger.warning(
      'Request to ${error.requestOptions.path} failed: ${error.type} '
      '(status: ${error.response?.statusCode}, data: ${error.response?.data})',
    );

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NoInternetFailure();
      case DioExceptionType.badCertificate:
        return const ServerFailure('failure.server_error');
      case DioExceptionType.badResponse:
        return _handleStatusCode(
          error.response?.statusCode,
          error.response?.data,
        );
      case DioExceptionType.cancel:
        return const UnexpectedFailure();
      case DioExceptionType.unknown:
        return const NoInternetFailure();
    }
  }

  /// Maps a non-2xx [Response] (allowed through by `validateStatus`) to a
  /// [Failure] without requiring a thrown [DioException].
  static Failure handleResponse(Response response) {
    _logger.warning(
      'Request to ${response.requestOptions.path} returned '
      '${response.statusCode}: ${response.data}',
    );
    return _handleStatusCode(response.statusCode, response.data);
  }

  static Failure _handleStatusCode(int? statusCode, dynamic responseData) {
    final errorBody =
        responseData is Map<String, dynamic> ? responseData['error'] : null;
    final apiErrorCode =
        errorBody is Map<String, dynamic> ? errorBody['code'] as int? : null;
    final apiMessage =
        errorBody is Map<String, dynamic>
            ? errorBody['message'] as String?
            : null;

    if (apiErrorCode == _cityNotFoundCode) {
      return WeatherFailure(apiMessage ?? 'failure.city_not_found');
    }

    final message = _statusCodeMessages[statusCode] ?? 'failure.unexpected';
    switch (statusCode) {
      case 401:
      case 403:
        return UnauthorizedFailure(message);
      case 404:
        return NotFoundFailure(message);
      case 429:
        return RateLimitFailure(message);
      case 500:
      case 502:
      case 503:
        return ServerFailure(message);
      default:
        return UnknownFailure(message);
    }
  }
}
