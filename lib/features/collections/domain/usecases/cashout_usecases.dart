import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/cashout_entity.dart';
import '../repositories/cashout_repository.dart';

class AddCashOutUseCase extends UseCase<CashOutEntity, CashOutEntity> {
  final CashOutRepository repository;
  AddCashOutUseCase(this.repository);

  @override
  Future<Either<Failure, CashOutEntity>> call(CashOutEntity params) async => repository.addCashOut(params);
}

class GetActiveCashOutsUseCase extends UseCase<List<CashOutEntity>, String?> {
  final CashOutRepository repository;
  GetActiveCashOutsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CashOutEntity>>> call(String? lineId) async => repository.getActiveCashOuts(lineId);
}

class GetCashOutHistoryUseCase extends UseCase<List<CashOutEntity>, String?> {
  final CashOutRepository repository;
  GetCashOutHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<CashOutEntity>>> call(String? lineId) async => repository.getCashOutHistory(lineId);
}

class SettleCashOutUseCase extends UseCase<void, String> {
  final CashOutRepository repository;
  SettleCashOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async => repository.settleCashOut(params);
}
