import '../../domain/entities/expense_entity.dart';

abstract class ExpensesEvent {}

class LoadExpensesRequested extends ExpensesEvent {
  final DateTime from;
  final DateTime to;
  final bool isInvestment;
  final String? lineId;

  LoadExpensesRequested({
    required this.from,
    required this.to,
    required this.isInvestment,
    this.lineId,
  });
}

class AddExpenseSubmitted extends ExpensesEvent {
  final ExpenseEntity expense;
  AddExpenseSubmitted(this.expense);
}
