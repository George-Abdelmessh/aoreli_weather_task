import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable implements Exception {
  const Failure(this.message);

  /// Localization key, e.g. 'failure.bad_request'.
  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, this.errors);

  final Map<String, List<String>> errors;

  @override
  List<Object?> get props => [message, errors];
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure() : super('failure.no_internet');
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure() : super('failure.unexpected');
}

/// Thrown when the API cannot resolve the requested city.
class WeatherFailure extends Failure {
  const WeatherFailure(super.message);
}
