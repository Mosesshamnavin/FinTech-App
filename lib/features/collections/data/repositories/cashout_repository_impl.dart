import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/cashout_entity.dart';
import '../../domain/repositories/cashout_repository.dart';
import '../datasources/cashout_remote_datasource.dart';
import '../models/cashout_model.dart';

class CashOutRepositoryImpl implements CashOutRepository {
  final CashOutRemoteDataSource remoteDataSource;

  CashOutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CashOutEntity>> addCashOut(CashOutEntity cashOut) async {
    try {
      final model = CashOutModel.fromEntity(cashOut);
      final result = await remoteDataSource.addCashOut(model);
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CashOutEntity>>> getActiveCashOuts(String? lineId) async {
    try {
      final result = await remoteDataSource.getActiveCashOuts(lineId);
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CashOutEntity>>> getCashOutHistory(String? lineId) async {
    try {
      final result = await remoteDataSource.getCashOutHistory(lineId);
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> settleCashOut(String id) async {
    try {
      await remoteDataSource.settleCashOut(id);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
