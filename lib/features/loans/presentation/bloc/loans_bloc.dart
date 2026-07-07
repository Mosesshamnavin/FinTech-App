import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_loan_usecase.dart';
import '../../domain/usecases/get_all_loans_usecase.dart';
import '../../domain/usecases/get_customer_loans_usecase.dart';
import '../../domain/usecases/update_loan_usecase.dart';
import '../../domain/usecases/delete_loan_usecase.dart';
import 'loans_event.dart';
import 'loans_state.dart';

class LoansBloc extends Bloc<LoansEvent, LoansState> {
  final GetAllLoansUseCase getAllLoans;
  final GetCustomerLoansUseCase getCustomerLoans;
  final AddLoanUseCase addLoan;
  final UpdateLoanUseCase updateLoan;
  final DeleteLoanUseCase deleteLoan;

  LoansBloc({
    required this.getAllLoans,
    required this.getCustomerLoans,
    required this.addLoan,
    required this.updateLoan,
    required this.deleteLoan,
  }) : super(LoansInitial()) {
    on<LoadAllLoansRequested>(_onLoadAll);
    on<LoadCustomerLoansRequested>(_onLoadCustomer);
    on<AddLoanSubmitted>(_onAddLoan);
    on<UpdateLoanSubmitted>(_onUpdateLoan);
    on<DeleteLoanSubmitted>(_onDeleteLoan);
  }

  Future<void> _onLoadAll(LoadAllLoansRequested event, Emitter<LoansState> emit) async {
    emit(LoansLoading());
    final either = await getAllLoans(NoParams());
    either.fold(
      (failure) => emit(LoansError(failure.message)),
      (loans) => emit(LoansLoaded(loans)),
    );
  }

  Future<void> _onLoadCustomer(LoadCustomerLoansRequested event, Emitter<LoansState> emit) async {
    emit(LoansLoading());
    final either = await getCustomerLoans(event.customerId);
    either.fold(
      (failure) => emit(LoansError(failure.message)),
      (loans) => emit(LoansLoaded(loans)),
    );
  }

  Future<void> _onAddLoan(AddLoanSubmitted event, Emitter<LoansState> emit) async {
    emit(LoansLoading());
    final either = await addLoan(event.loan);
    either.fold(
      (failure) => emit(LoansError(failure.message)),
      (_) => add(LoadAllLoansRequested()),
    );
  }

  Future<void> _onUpdateLoan(UpdateLoanSubmitted event, Emitter<LoansState> emit) async {
    emit(LoansLoading());
    final either = await updateLoan(event.loan);
    either.fold(
      (failure) => emit(LoansError(failure.message)),
      (_) => add(LoadAllLoansRequested()),
    );
  }

  Future<void> _onDeleteLoan(DeleteLoanSubmitted event, Emitter<LoansState> emit) async {
    emit(LoansLoading());
    final either = await deleteLoan(event.id);
    either.fold(
      (failure) => emit(LoansError(failure.message)),
      (_) => add(LoadAllLoansRequested()),
    );
  }
}
