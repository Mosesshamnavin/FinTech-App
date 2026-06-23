import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class AddExpenseUseCase extends UseCase<ExpenseEntity, ExpenseEntity> {
  final ExpenseRepository repository;
  AddExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, ExpenseEntity>> call(ExpenseEntity params) async {
    return repository.addExpense(params);
  }
}
