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
  Future<Either<Failure, void>> updateArea(AreaEntity area);
  Future<Either<Failure, void>> deleteArea(String id);
  Future<Either<Failure, List<AreaEntity>>> getAreas();

  Future<Either<Failure, LineTypeEntity>> addLineType(LineTypeEntity lineType);
  Future<Either<Failure, void>> updateLineType(LineTypeEntity lineType);
  Future<Either<Failure, void>> deleteLineType(String id);
  Future<Either<Failure, List<LineTypeEntity>>> getLineTypes();

  Future<Either<Failure, LineEntity>> addLine(LineEntity line);
  Future<Either<Failure, void>> updateLine(LineEntity line);
  Future<Either<Failure, void>> deleteLine(String id);
  Future<Either<Failure, List<LineEntity>>> getLines();
}
