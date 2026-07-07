import '../entities/loan_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';

abstract class LoanRepository {
  Future<Either<Failure, LoanEntity>> addLoan(LoanEntity loan);
  Future<Either<Failure, List<LoanEntity>>> getAllLoans();
  Future<Either<Failure, List<LoanEntity>>> getLoansByCustomer(String customerId);
  Future<Either<Failure, void>> updateLoan(LoanEntity loan);
  Future<Either<Failure, void>> deleteLoan(String id);
}
