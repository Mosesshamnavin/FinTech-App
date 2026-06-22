import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends UseCaseNoParams<void> {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
