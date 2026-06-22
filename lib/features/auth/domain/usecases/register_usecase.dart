import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase extends UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    if (params.name.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Name is required.')));
    }
    if (params.username.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Username is required.')));
    }
    if (params.password.length < 6) {
      return Future.value(Left(const ValidationFailure('Password must be at least 6 characters.')));
    }
    if (params.password != params.confirmPassword) {
      return Future.value(Left(const ValidationFailure('Passwords do not match.')));
    }
    if (!params.email.contains('@')) {
      return Future.value(Left(const ValidationFailure('Enter a valid email address.')));
    }
    return repository.register(
      name: params.name.trim(),
      username: params.username.trim(),
      password: params.password,
      email: params.email.trim(),
      mobile: params.mobile.trim(),
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String username;
  final String password;
  final String confirmPassword;
  final String email;
  final String mobile;

  const RegisterParams({
    required this.name,
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.email,
    required this.mobile,
  });

  @override
  List<Object> get props => [name, username, password, confirmPassword, email, mobile];
}
