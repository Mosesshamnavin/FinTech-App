import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_customer_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';
import '../../domain/usecases/delete_customer_usecase.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final GetCustomersUseCase getCustomersUseCase;
  final AddCustomerUseCase addCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  CustomersBloc({
    required this.getCustomersUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
  }) : super(const CustomersInitial()) {
    on<LoadCustomersRequested>(_onLoadCustomersRequested);
    on<AddCustomerSubmitted>(_onAddCustomerSubmitted);
    on<UpdateCustomerSubmitted>(_onUpdateCustomerSubmitted);
    on<DeleteCustomerSubmitted>(_onDeleteCustomerSubmitted);
  }

  Future<void> _onLoadCustomersRequested(
    LoadCustomersRequested event,
    Emitter<CustomersState> emit,
  ) async {
    emit(const CustomersLoading());
    final result = await getCustomersUseCase(
      GetCustomersParams(lineId: event.lineId, areaId: event.areaId),
    );

    result.fold(
      (failure) => emit(CustomersError(failure.message)),
      (customers) => emit(CustomersLoaded(customers)),
    );
  }

  Future<void> _onAddCustomerSubmitted(
    AddCustomerSubmitted event,
    Emitter<CustomersState> emit,
  ) async {
    emit(const AddCustomerLoading());
    final result = await addCustomerUseCase(
      AddCustomerParams(
        name: event.name,
        phone: event.phone,
        address: event.address,
        lineId: event.lineId,
        areaId: event.areaId,
      ),
    );

    result.fold(
      (failure) => emit(AddCustomerError(failure.message)),
      (customer) => emit(AddCustomerSuccess(customer)),
    );
  }

  Future<void> _onUpdateCustomerSubmitted(
    UpdateCustomerSubmitted event,
    Emitter<CustomersState> emit,
  ) async {
    emit(const UpdateCustomerLoading());
    final result = await updateCustomerUseCase(
      UpdateCustomerParams(
        id: event.id,
        name: event.name,
        phone: event.phone,
        address: event.address,
        lineId: event.lineId,
        areaId: event.areaId,
      ),
    );

    result.fold(
      (failure) => emit(UpdateCustomerError(failure.message)),
      (customer) => emit(UpdateCustomerSuccess(customer)),
    );
  }

  Future<void> _onDeleteCustomerSubmitted(
    DeleteCustomerSubmitted event,
    Emitter<CustomersState> emit,
  ) async {
    emit(const DeleteCustomerLoading());
    final result = await deleteCustomerUseCase(event.id);

    result.fold(
      (failure) => emit(DeleteCustomerError(failure.message)),
      (_) => emit(const DeleteCustomerSuccess()),
    );
  }
}
