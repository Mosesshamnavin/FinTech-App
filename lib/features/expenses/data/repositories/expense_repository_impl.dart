import '../../domain/repositories/expense_repository.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../datasources/expense_remote_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense) async {
    try {
      final result = await remoteDataSource.addExpense(expense);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses({
    required DateTime from,
    required DateTime to,
    required bool isInvestment,
    String? lineId,
  }) async {
    try {
      final result = await remoteDataSource.getExpenses(
        from: from,
        to: to,
        isInvestment: isInvestment,
        lineId: lineId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }
}
