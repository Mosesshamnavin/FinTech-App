import '../../domain/entities/loan_entity.dart';

abstract class LoansEvent {}

class LoadAllLoansRequested extends LoansEvent {}

class LoadCustomerLoansRequested extends LoansEvent {
  final String customerId;
  LoadCustomerLoansRequested(this.customerId);
}

class AddLoanSubmitted extends LoansEvent {
  final LoanEntity loan;
  AddLoanSubmitted(this.loan);
}
