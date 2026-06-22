import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failures from server / network responses
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

/// Failures from local cache / storage
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data error.']);
}

/// Failures from invalid credentials or auth issues
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Invalid username or password.']);
}

/// Failures from no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// Failures from validation (e.g. empty fields)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
