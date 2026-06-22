import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class AddCustomerUseCase extends UseCase<CustomerEntity, AddCustomerParams> {
  final CustomerRepository repository;

  AddCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, CustomerEntity>> call(AddCustomerParams params) {
    if (params.name.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Name is required.')));
    }
    if (params.phone.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Phone is required.')));
    }
    if (params.address.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Address is required.')));
    }
    if (params.lineId.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Line is required.')));
    }
    if (params.areaId.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Area is required.')));
    }

    return repository.addCustomer(
      name: params.name.trim(),
      phone: params.phone.trim(),
      address: params.address.trim(),
      lineId: params.lineId.trim(),
      areaId: params.areaId.trim(),
    );
  }
}

class AddCustomerParams extends Equatable {
  final String name;
  final String phone;
  final String address;
  final String lineId;
  final String areaId;

  const AddCustomerParams({
    required this.name,
    required this.phone,
    required this.address,
    required this.lineId,
    required this.areaId,
  });

  @override
  List<Object> get props => [name, phone, address, lineId, areaId];
}
