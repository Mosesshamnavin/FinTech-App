import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ReportEntity>> getDailySummary({
    required String date,
    String? lineType,
    String? line,
  }) async {
    try {
      final report = await remoteDataSource.getDailySummary(
        date: date,
        lineType: lineType,
        line: line,
      );
      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> getLineSummary({
    required String fromDate,
    required String toDate,
    String? lineType,
    String? line,
    bool all = true,
  }) async {
    try {
      final report = await remoteDataSource.getLineSummary(
        fromDate: fromDate,
        toDate: toDate,
        lineType: lineType,
        line: line,
        all: all,
      );
      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> getNewCustomerSummary({
    required String fromDate,
    required String toDate,
    String? lineType,
    String? line,
    bool all = true,
  }) async {
    try {
      final report = await remoteDataSource.getNewCustomerSummary(
        fromDate: fromDate,
        toDate: toDate,
        lineType: lineType,
        line: line,
        all: all,
      );
      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }
}
