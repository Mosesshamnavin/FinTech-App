import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  Future<Either<Failure, ExpenseEntity>> call(ExpenseEntity expense) async {
    return await repository.updateExpense(expense);
  }
}
