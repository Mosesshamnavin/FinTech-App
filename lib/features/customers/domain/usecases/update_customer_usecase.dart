import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomerUseCase {
  final CustomerRepository repository;

  UpdateCustomerUseCase(this.repository);

  Future<Either<Failure, CustomerEntity>> call(UpdateCustomerParams params) {
    return repository.updateCustomer(
      id: params.id,
      name: params.name,
      phone: params.phone,
      address: params.address,
      lineId: params.lineId,
      areaId: params.areaId,
    );
  }
}

class UpdateCustomerParams {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String lineId;
  final String areaId;

  UpdateCustomerParams({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.lineId,
    required this.areaId,
  });
}
