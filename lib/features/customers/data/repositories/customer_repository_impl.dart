import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({
    String? lineId,
    String? areaId,
  }) async {
    try {
      final customers = await remoteDataSource.getCustomers(
        lineId: lineId,
        areaId: areaId,
      );
      return Right(customers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> addCustomer({
    required String name,
    required String phone,
    required String address,
    required String lineId,
    required String areaId,
  }) async {
    try {
      final customer = await remoteDataSource.addCustomer(
        name: name,
        phone: phone,
        address: address,
        lineId: lineId,
        areaId: areaId,
      );
      return Right(customer);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
