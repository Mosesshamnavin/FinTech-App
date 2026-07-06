import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense);
  Future<Either<Failure, ExpenseEntity>> updateExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> deleteExpense(String id, bool isInvestment);
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses({
    required DateTime from,
    required DateTime to,
    required bool isInvestment,
    String? lineId,
  });
}
