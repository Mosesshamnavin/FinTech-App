import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/customer_repository.dart';

class DeleteCustomerUseCase {
  final CustomerRepository repository;

  DeleteCustomerUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteCustomer(id);
  }
}
