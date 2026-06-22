import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Retrieves the currently logged-in user from local cache.
/// Used on app startup to determine if user should see login or home screen.
class GetCachedUserUseCase extends UseCaseNoParams<UserEntity?> {
  final AuthRepository repository;
  GetCachedUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call() {
    return repository.getCachedUser();
  }
}
