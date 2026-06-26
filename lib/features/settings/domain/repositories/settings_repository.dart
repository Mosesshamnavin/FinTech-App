import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/settings_entities.dart';

abstract class SettingsRepository {
  Future<Either<Failure, ExpenseTypeEntity>> addExpenseType(ExpenseTypeEntity expenseType);
  Future<Either<Failure, void>> updateExpenseType(ExpenseTypeEntity expenseType);
  Future<Either<Failure, void>> deleteExpenseType(String id);
  Future<Either<Failure, List<ExpenseTypeEntity>>> getExpenseTypes();

  Future<Either<Failure, InvestmentTypeEntity>> addInvestmentType(InvestmentTypeEntity investmentType);
  Future<Either<Failure, void>> updateInvestmentType(InvestmentTypeEntity investmentType);
  Future<Either<Failure, void>> deleteInvestmentType(String id);
  Future<Either<Failure, List<InvestmentTypeEntity>>> getInvestmentTypes();

  Future<Either<Failure, AreaEntity>> addArea(AreaEntity area);
  Future<Either<Failure, List<AreaEntity>>> getAreas();

  Future<Either<Failure, LineEntity>> addLine(LineEntity line);
  Future<Either<Failure, List<LineEntity>>> getLines();
}
