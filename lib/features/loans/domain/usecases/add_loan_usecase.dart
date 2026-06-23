import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/loan_entity.dart';
import '../repositories/loan_repository.dart';

class AddLoanUseCase extends UseCase<LoanEntity, LoanEntity> {
  final LoanRepository repository;
  AddLoanUseCase(this.repository);

  @override
  Future<Either<Failure, LoanEntity>> call(LoanEntity params) async {
    return repository.addLoan(params);
  }
}
