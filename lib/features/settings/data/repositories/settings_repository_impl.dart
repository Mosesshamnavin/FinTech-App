import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/settings_entities.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ExpenseTypeEntity>> addExpenseType(ExpenseTypeEntity expenseType) async {
    try {
      final result = await remoteDataSource.addExpenseType(expenseType);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ExpenseTypeEntity>>> getExpenseTypes() async {
    try {
      final result = await remoteDataSource.getExpenseTypes();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, InvestmentTypeEntity>> addInvestmentType(InvestmentTypeEntity investmentType) async {
    try {
      final result = await remoteDataSource.addInvestmentType(investmentType);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<InvestmentTypeEntity>>> getInvestmentTypes() async {
    try {
      final result = await remoteDataSource.getInvestmentTypes();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AreaEntity>> addArea(AreaEntity area) async {
    try {
      final result = await remoteDataSource.addArea(area);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AreaEntity>>> getAreas() async {
    try {
      final result = await remoteDataSource.getAreas();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, LineEntity>> addLine(LineEntity line) async {
    try {
      final result = await remoteDataSource.addLine(line);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<LineEntity>>> getLines() async {
    try {
      final result = await remoteDataSource.getLines();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }
}
