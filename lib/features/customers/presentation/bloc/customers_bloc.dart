import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_customer_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final GetCustomersUseCase getCustomersUseCase;
  final AddCustomerUseCase addCustomerUseCase;

  CustomersBloc({
    required this.getCustomersUseCase,
    required this.addCustomerUseCase,
  }) : super(const CustomersInitial()) {
    on<LoadCustomersRequested>(_onLoadCustomersRequested);
    on<AddCustomerSubmitted>(_onAddCustomerSubmitted);
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
}
