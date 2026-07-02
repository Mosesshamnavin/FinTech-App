import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  ReportRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, ReportEntity>> _call(Future<ReportEntity> Function() fn) async {
    try { return Right(await fn()); } on ServerException catch (e) { return Left(ServerFailure(e.message)); } catch (e) { return Left(ServerFailure(e.toString())); }
  }

  @override Future<Either<Failure, ReportEntity>> getPlanReport({String? line}) => _call(() => remoteDataSource.getPlanReport(line: line));
  @override Future<Either<Failure, ReportEntity>> getDailySummary({required String date, String? lineType, String? line}) => _call(() => remoteDataSource.getDailySummary(date: date, lineType: lineType, line: line));
  @override Future<Either<Failure, ReportEntity>> getLineSummary({required String fromDate, required String toDate, String? lineType, String? line, bool all = true}) => _call(() => remoteDataSource.getLineSummary(fromDate: fromDate, toDate: toDate, lineType: lineType, line: line, all: all));
  @override Future<Either<Failure, ReportEntity>> getNewCustomerSummary({required String fromDate, required String toDate, String? lineType, String? line, bool all = true}) => _call(() => remoteDataSource.getNewCustomerSummary(fromDate: fromDate, toDate: toDate, lineType: lineType, line: line, all: all));
  @override Future<Either<Failure, ReportEntity>> getLoanSummary({required String fromDate, required String toDate, String? line}) => _call(() => remoteDataSource.getLoanSummary(fromDate: fromDate, toDate: toDate, line: line));
  @override Future<Either<Failure, ReportEntity>> getExpenseSummary({required String fromDate, required String toDate, String? line}) => _call(() => remoteDataSource.getExpenseSummary(fromDate: fromDate, toDate: toDate, line: line));
  @override Future<Either<Failure, ReportEntity>> getCompletedLoanSummary({required String fromDate, required String toDate, String? line}) => _call(() => remoteDataSource.getCompletedLoanSummary(fromDate: fromDate, toDate: toDate, line: line));
  @override Future<Either<Failure, ReportEntity>> getBadLoanSummary({int minDays = 150, int maxDays = 999999, String? line}) => _call(() => remoteDataSource.getBadLoanSummary(minDays: minDays, maxDays: maxDays, line: line));
  @override Future<Either<Failure, ReportEntity>> getMissingCustomerSummary({required String date, String? line}) => _call(() => remoteDataSource.getMissingCustomerSummary(date: date, line: line));
  @override Future<Either<Failure, ReportEntity>> getInvestmentSummary({required String fromDate, required String toDate, String? line}) => _call(() => remoteDataSource.getInvestmentSummary(fromDate: fromDate, toDate: toDate, line: line));
  @override Future<Either<Failure, ReportEntity>> getInvestmentExpenseSummary({required String fromDate, required String toDate}) => _call(() => remoteDataSource.getInvestmentExpenseSummary(fromDate: fromDate, toDate: toDate));
  @override Future<Either<Failure, ReportEntity>> getLedgerReport({required String fromDate, required String toDate, String? lineId}) => _call(() => remoteDataSource.getLedgerReport(fromDate: fromDate, toDate: toDate, lineId: lineId));
  @override Future<Either<Failure, ReportEntity>> getAboutToCloseLoanSummary({int withinDays = 30, String? line}) => _call(() => remoteDataSource.getAboutToCloseLoanSummary(withinDays: withinDays, line: line));
  @override Future<Either<Failure, ReportEntity>> getMonthlyInterestPendingSummary({required int month, required int year, String? line}) => _call(() => remoteDataSource.getMonthlyInterestPendingSummary(month: month, year: year, line: line));
  @override Future<Either<Failure, ReportEntity>> getNonPerformanceLoanSummary({int minDays = 90, String? line}) => _call(() => remoteDataSource.getNonPerformanceLoanSummary(minDays: minDays, line: line));
  @override Future<Either<Failure, ReportEntity>> getNewBadLoanByDateSummary({required String fromDate, required String toDate, String? line}) => _call(() => remoteDataSource.getNewBadLoanByDateSummary(fromDate: fromDate, toDate: toDate, line: line));
  @override Future<Either<Failure, ReportEntity>> getLoanAnalysis({required String fromDate, required String toDate, String? line}) => _call(() => remoteDataSource.getLoanAnalysis(fromDate: fromDate, toDate: toDate, line: line));
  @override Future<Either<Failure, ReportEntity>> getOnlineCollectionSummary({required String fromDate, required String toDate, String? line}) => _call(() => remoteDataSource.getOnlineCollectionSummary(fromDate: fromDate, toDate: toDate, line: line));
  @override Future<Either<Failure, ReportEntity>> getSiteDashboardSummary({required String date}) => _call(() => remoteDataSource.getSiteDashboardSummary(date: date));
  @override Future<Either<Failure, ReportEntity>> getBookExcessLossSummary({required String fromDate, required String toDate}) => _call(() => remoteDataSource.getBookExcessLossSummary(fromDate: fromDate, toDate: toDate));
}
