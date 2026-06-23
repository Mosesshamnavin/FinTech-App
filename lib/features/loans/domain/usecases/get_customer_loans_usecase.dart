import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/loan_entity.dart';
import '../repositories/loan_repository.dart';

class GetCustomerLoansUseCase extends UseCase<List<LoanEntity>, String> {
  final LoanRepository repository;
  GetCustomerLoansUseCase(this.repository);

  @override
  Future<Either<Failure, List<LoanEntity>>> call(String customerId) async {
    return repository.getLoansByCustomer(customerId);
  }
}
