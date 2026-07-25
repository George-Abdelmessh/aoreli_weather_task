import 'package:dio/dio.dart';

import 'failure.dart';

/// Canonical API error handler.
///
/// TODO: log every error (endpoint, DioExceptionType, status code, response
/// data) via the `logging` package before mapping it.
class ApiErrorHandler {
  ApiErrorHandler._();

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
    // TODO: switch on error.type (timeouts -> NoInternetFailure,
    // badCertificate -> ServerFailure, badResponse -> _handleStatusCode, etc.)
    throw UnimplementedError();
  }

  static Failure _handleStatusCode(int? statusCode, dynamic responseData) {
    // TODO: parse validation errors (422) and extract human-readable message,
    // falling back to _statusCodeMessages.
    throw UnimplementedError();
  }
}
