import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();

  @override
  List<Object?> get props => [];
}

class CustomersInitial extends CustomersState {
  const CustomersInitial();
}

class CustomersLoading extends CustomersState {
  const CustomersLoading();
}

class CustomersLoaded extends CustomersState {
  final List<CustomerEntity> customers;
  
  const CustomersLoaded(this.customers);

  @override
  List<Object> get props => [customers];
}

class CustomersError extends CustomersState {
  final String message;

  const CustomersError(this.message);

  @override
  List<Object> get props => [message];
}

class AddCustomerLoading extends CustomersState {
  const AddCustomerLoading();
}

class AddCustomerSuccess extends CustomersState {
  final CustomerEntity newCustomer;

  const AddCustomerSuccess(this.newCustomer);

  @override
  List<Object> get props => [newCustomer];
}

class AddCustomerError extends CustomersState {
  final String message;

  const AddCustomerError(this.message);

  @override
  List<Object> get props => [message];
}
