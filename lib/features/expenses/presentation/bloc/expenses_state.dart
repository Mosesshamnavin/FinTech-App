import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();
  @override
  List<Object?> get props => [];
}

class ExpensesInitial extends ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<ExpenseEntity> expenses;
  const ExpensesLoaded(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

class ExpensesError extends ExpensesState {
  final String message;
  const ExpensesError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddExpenseSuccess extends ExpensesState {}

class UpdateExpenseSuccess extends ExpensesState {}

class DeleteExpenseSuccess extends ExpensesState {}

class ExpenseActionError extends ExpensesState {
  final String message;
  const ExpenseActionError(this.message);

  @override
  List<Object?> get props => [message];
}
