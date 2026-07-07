import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/loan_entity.dart';
import '../repositories/loan_repository.dart';

class UpdateLoanUseCase {
  final LoanRepository repository;

  UpdateLoanUseCase(this.repository);

  Future<Either<Failure, void>> call(LoanEntity loan) async {
    return await repository.updateLoan(loan);
  }
}
