import '../error/failures.dart';
import '../utils/either.dart';

/// Base class for all use cases that take parameters.
///
/// Usage:
///   class LoginUseCase extends UseCase<User, LoginParams> { ... }
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases that take no parameters.
///
/// Usage:
///   class GetCachedUserUseCase extends UseCaseNoParams<User> { ... }
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Sentinel class for use cases that take no parameters (pass NoParams()).
class NoParams {}
