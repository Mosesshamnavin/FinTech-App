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
  Future<Either<Failure, void>> updateExpenseType(ExpenseTypeEntity expenseType) async {
    try {
      await remoteDataSource.updateExpenseType(expenseType);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpenseType(String id) async {
    try {
      await remoteDataSource.deleteExpenseType(id);
      return const Right(null);
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
  Future<Either<Failure, void>> updateInvestmentType(InvestmentTypeEntity investmentType) async {
    try {
      await remoteDataSource.updateInvestmentType(investmentType);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvestmentType(String id) async {
    try {
      await remoteDataSource.deleteInvestmentType(id);
      return const Right(null);
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
  Future<Either<Failure, void>> updateArea(AreaEntity area) async {
    try {
      await remoteDataSource.updateArea(area);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteArea(String id) async {
    try {
      await remoteDataSource.deleteArea(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, LineTypeEntity>> addLineType(LineTypeEntity lineType) async {
    try {
      final result = await remoteDataSource.addLineType(lineType);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateLineType(LineTypeEntity lineType) async {
    try {
      await remoteDataSource.updateLineType(lineType);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteLineType(String id) async {
    try {
      await remoteDataSource.deleteLineType(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<LineTypeEntity>>> getLineTypes() async {
    try {
      final result = await remoteDataSource.getLineTypes();
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

  @override
  Future<Either<Failure, void>> updateLine(LineEntity line) async {
    try {
      await remoteDataSource.updateLine(line);
      return const Right(null);
    } on ServerException catch (e) {
      print('ServerException updating line: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('Generic Exception updating line: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLine(String id) async {
    try {
      await remoteDataSource.deleteLine(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }
}
