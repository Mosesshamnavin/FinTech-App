import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final GetExpensesUseCase getExpenses;
  final AddExpenseUseCase addExpense;
  final UpdateExpenseUseCase updateExpense;
  final DeleteExpenseUseCase deleteExpense;

  // We keep track of the last query params so we can reload after adding
  LoadExpensesRequested? _lastLoadEvent;

  ExpensesBloc({
    required this.getExpenses,
    required this.addExpense,
    required this.updateExpense,
    required this.deleteExpense,
  }) : super(ExpensesInitial()) {
    on<LoadExpensesRequested>(_onLoadExpenses);
    on<AddExpenseSubmitted>(_onAddExpense);
    on<UpdateExpenseSubmitted>(_onUpdateExpense);
    on<DeleteExpenseSubmitted>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(LoadExpensesRequested event, Emitter<ExpensesState> emit) async {
    _lastLoadEvent = event;
    emit(ExpensesLoading());
    final either = await getExpenses(GetExpensesParams(
      from: event.from,
      to: event.to,
      isInvestment: event.isInvestment,
      lineId: event.lineId,
    ));
    either.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (expenses) => emit(ExpensesLoaded(expenses)),
    );
  }

  Future<void> _onAddExpense(AddExpenseSubmitted event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final either = await addExpense(event.expense);
    either.fold(
      (failure) => emit(ExpenseActionError(failure.message)),
      (_) {
        emit(AddExpenseSuccess());
        if (_lastLoadEvent != null) add(_lastLoadEvent!);
      },
    );
  }

  Future<void> _onUpdateExpense(UpdateExpenseSubmitted event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final either = await updateExpense(event.expense);
    either.fold(
      (failure) => emit(ExpenseActionError(failure.message)),
      (_) {
        emit(UpdateExpenseSuccess());
        if (_lastLoadEvent != null) add(_lastLoadEvent!);
      },
    );
  }

  Future<void> _onDeleteExpense(DeleteExpenseSubmitted event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final either = await deleteExpense(event.id, event.isInvestment);
    either.fold(
      (failure) => emit(ExpenseActionError(failure.message)),
      (_) {
        emit(DeleteExpenseSuccess());
        if (_lastLoadEvent != null) add(_lastLoadEvent!);
      },
    );
  }
}
