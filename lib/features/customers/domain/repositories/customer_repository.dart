import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({
    String? lineId,
    String? areaId,
  });

  Future<Either<Failure, CustomerEntity>> addCustomer({
    required String name,
    required String phone,
    required String address,
    required String lineId,
    required String areaId,
  });
}
