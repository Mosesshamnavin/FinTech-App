import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/loan_entity.dart';
import '../repositories/loan_repository.dart';

class GetAllLoansUseCase extends UseCase<List<LoanEntity>, NoParams> {
  final LoanRepository repository;
  GetAllLoansUseCase(this.repository);

  @override
  Future<Either<Failure, List<LoanEntity>>> call(NoParams params) async {
    return repository.getAllLoans();
  }
}
