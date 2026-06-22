import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../customers/data/datasources/customer_remote_datasource.dart';
import '../../domain/entities/collection_entity.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_remote_datasource.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionRemoteDataSource collectionRemoteDataSource;
  final CustomerRemoteDataSource customerRemoteDataSource;

  CollectionRepositoryImpl({
    required this.collectionRemoteDataSource,
    required this.customerRemoteDataSource,
  });

  @override
  Future<Either<Failure, List<DailyCollectionCustomerEntity>>> getDailyCollections({
    required String date,
    String? lineId,
    String? areaId,
  }) async {
    try {
      // 1. Fetch filtered customers
      final customers = await customerRemoteDataSource.getCustomers(
        lineId: lineId,
        areaId: areaId,
      );

      // 2. Fetch collections for the specific date
      final collectionsForDate = await collectionRemoteDataSource.getCollectionsByDate(date);

      // 3. Map them together
      final List<DailyCollectionCustomerEntity> dailyList = customers.map((customer) {
        // Find if this customer has a collection record for today
        final collectionRecord = collectionsForDate.where((c) => c.customerId == customer.id).firstOrNull;
        
        return DailyCollectionCustomerEntity(
          customer: customer,
          collection: collectionRecord,
        );
      }).toList();

      return Right(dailyList);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CollectionEntity>> addCollection({
    required String customerId,
    required double amount,
    required String date,
    String? notes,
    required String status,
  }) async {
    try {
      final collection = await collectionRemoteDataSource.addCollection(
        customerId: customerId,
        amount: amount,
        date: date,
        notes: notes,
        status: status,
      );
      return Right(collection);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
