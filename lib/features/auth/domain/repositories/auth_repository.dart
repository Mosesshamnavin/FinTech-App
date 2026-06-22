import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';

/// Abstract contract for authentication operations.
/// The data layer provides the concrete implementation.
/// This abstraction allows swapping mock → real Hasura without touching BLoC or UI.
abstract class AuthRepository {
  /// Authenticate with username and password.
  /// Returns [UserEntity] on success or [Failure] on error.
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  });

  /// Register a new account.
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String username,
    required String password,
    required String email,
    required String mobile,
  });

  /// Log the current user out and clear stored credentials.
  Future<Either<Failure, void>> logout();

  /// Send OTP to registered email for password reset.
  Future<Either<Failure, void>> sendOtp({required String username});

  /// Reset password using OTP.
  Future<Either<Failure, void>> resetPassword({
    required String otp,
    required String newPassword,
  });

  /// Get the currently cached/logged-in user from local storage.
  /// Returns null if no user is logged in.
  Future<Either<Failure, UserEntity?>> getCachedUser();
}
