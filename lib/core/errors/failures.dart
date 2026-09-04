import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Unable to connect to the campus network. Please check your internet.'])
      : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Session expired. Please log in again.'])
      : super(message, 401);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message, 422);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure(String message) : super(message, 429);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'The requested resource was not found.'])
      : super(message, 404);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'A server error occurred. Please try again later.'])
      : super(message, 500);
}

class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'You do not have permission to perform this action.'])
      : super(message, 403);
}
