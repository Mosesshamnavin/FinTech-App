import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/cashout_entity.dart';

abstract class CashOutRepository {
  Future<Either<Failure, CashOutEntity>> addCashOut(CashOutEntity cashOut);
  Future<Either<Failure, List<CashOutEntity>>> getActiveCashOuts(String? lineId);
  Future<Either<Failure, List<CashOutEntity>>> getCashOutHistory(String? lineId);
  Future<Either<Failure, void>> settleCashOut(String id);
}
