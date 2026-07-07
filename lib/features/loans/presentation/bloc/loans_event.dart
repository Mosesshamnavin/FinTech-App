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

class UpdateLoanSubmitted extends LoansEvent {
  final LoanEntity loan;
  UpdateLoanSubmitted(this.loan);
}

class DeleteLoanSubmitted extends LoansEvent {
  final String id;
  DeleteLoanSubmitted(this.id);
}
