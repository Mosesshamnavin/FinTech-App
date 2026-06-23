import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/settings_entities.dart';
import '../repositories/settings_repository.dart';

// --- Expense Types ---
class AddExpenseTypeUseCase extends UseCase<ExpenseTypeEntity, ExpenseTypeEntity> {
  final SettingsRepository repository;
  AddExpenseTypeUseCase(this.repository);
  @override
  Future<Either<Failure, ExpenseTypeEntity>> call(ExpenseTypeEntity params) async => repository.addExpenseType(params);
}

class GetExpenseTypesUseCase extends UseCase<List<ExpenseTypeEntity>, NoParams> {
  final SettingsRepository repository;
  GetExpenseTypesUseCase(this.repository);
  @override
  Future<Either<Failure, List<ExpenseTypeEntity>>> call(NoParams params) async => repository.getExpenseTypes();
}

// --- Investment Types ---
class AddInvestmentTypeUseCase extends UseCase<InvestmentTypeEntity, InvestmentTypeEntity> {
  final SettingsRepository repository;
  AddInvestmentTypeUseCase(this.repository);
  @override
  Future<Either<Failure, InvestmentTypeEntity>> call(InvestmentTypeEntity params) async => repository.addInvestmentType(params);
}

class GetInvestmentTypesUseCase extends UseCase<List<InvestmentTypeEntity>, NoParams> {
  final SettingsRepository repository;
  GetInvestmentTypesUseCase(this.repository);
  @override
  Future<Either<Failure, List<InvestmentTypeEntity>>> call(NoParams params) async => repository.getInvestmentTypes();
}

// --- Areas ---
class AddAreaUseCase extends UseCase<AreaEntity, AreaEntity> {
  final SettingsRepository repository;
  AddAreaUseCase(this.repository);
  @override
  Future<Either<Failure, AreaEntity>> call(AreaEntity params) async => repository.addArea(params);
}

class GetAreasUseCase extends UseCase<List<AreaEntity>, NoParams> {
  final SettingsRepository repository;
  GetAreasUseCase(this.repository);
  @override
  Future<Either<Failure, List<AreaEntity>>> call(NoParams params) async => repository.getAreas();
}

// --- Lines ---
class AddLineUseCase extends UseCase<LineEntity, LineEntity> {
  final SettingsRepository repository;
  AddLineUseCase(this.repository);
  @override
  Future<Either<Failure, LineEntity>> call(LineEntity params) async => repository.addLine(params);
}

class GetLinesUseCase extends UseCase<List<LineEntity>, NoParams> {
  final SettingsRepository repository;
  GetLinesUseCase(this.repository);
  @override
  Future<Either<Failure, List<LineEntity>>> call(NoParams params) async => repository.getLines();
}
