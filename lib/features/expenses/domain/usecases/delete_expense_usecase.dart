import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, bool isInvestment) async {
    return await repository.deleteExpense(id, isInvestment);
  }
}
