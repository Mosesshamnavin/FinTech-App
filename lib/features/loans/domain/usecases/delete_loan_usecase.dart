import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/loan_repository.dart';

class DeleteLoanUseCase {
  final LoanRepository repository;

  DeleteLoanUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteLoan(id);
  }
}
