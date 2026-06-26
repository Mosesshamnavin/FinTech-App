import '../../domain/entities/expense_entity.dart';
import '../../../../core/error/exceptions.dart';

abstract class ExpenseRemoteDataSource {
  Future<ExpenseEntity> addExpense(ExpenseEntity expense);

  Future<List<ExpenseEntity>> getExpenses({
    required DateTime from,
    required DateTime to,
    required bool isInvestment,
    String? lineId,
  });
}
