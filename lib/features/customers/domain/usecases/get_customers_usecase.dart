import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase extends UseCase<List<CustomerEntity>, GetCustomersParams> {
  final CustomerRepository repository;

  GetCustomersUseCase(this.repository);

  @override
  Future<Either<Failure, List<CustomerEntity>>> call(GetCustomersParams params) {
    return repository.getCustomers(
      lineId: params.lineId,
      areaId: params.areaId,
    );
  }
}

class GetCustomersParams extends Equatable {
  final String? lineId;
  final String? areaId;

  const GetCustomersParams({this.lineId, this.areaId});

  @override
  List<Object?> get props => [lineId, areaId];
}
