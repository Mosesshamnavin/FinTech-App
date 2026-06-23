import '../../domain/entities/expense_entity.dart';
import '../../../../core/error/exceptions.dart';

class ExpenseRemoteDataSource {
  final List<ExpenseEntity> _expenses = [];

  ExpenseRemoteDataSource() {
    _expenses.addAll([
      ExpenseEntity(
        id: 'E001',
        amount: 250,
        category: 'Food',
        description: 'Lunch',
        date: DateTime.now(),
        isInvestment: false,
        isOnline: false,
      ),
      ExpenseEntity(
        id: 'I001',
        amount: 5000,
        category: 'Fixed Deposit',
        description: 'Monthly Investment',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isInvestment: true,
        isOnline: true,
      ),
    ]);
  }

  Future<ExpenseEntity> addExpense(ExpenseEntity expense) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _expenses.add(expense);
    return expense;
  }

  Future<List<ExpenseEntity>> getExpenses({
    required DateTime from,
    required DateTime to,
    required bool isInvestment,
    String? lineId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _expenses.where((e) {
      final matchesTab = e.isInvestment == isInvestment;
      final isAfterOrEqualFrom = e.date.isAfter(from.subtract(const Duration(days: 1)));
      final isBeforeOrEqualTo = e.date.isBefore(to.add(const Duration(days: 1)));
      final matchesLine = lineId == null || lineId == 'All' || e.lineId == lineId;

      return matchesTab && isAfterOrEqualFrom && isBeforeOrEqualTo && matchesLine;
    }).toList();
  }
}
