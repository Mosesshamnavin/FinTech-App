import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, ReportEntity>> getPlanReport({String? line});
  Future<Either<Failure, ReportEntity>> getDailySummary({required String date, String? lineType, String? line});
  Future<Either<Failure, ReportEntity>> getLineSummary({required String fromDate, required String toDate, String? lineType, String? line, bool all = true});
  Future<Either<Failure, ReportEntity>> getNewCustomerSummary({required String fromDate, required String toDate, String? lineType, String? line, bool all = true});
  Future<Either<Failure, ReportEntity>> getLoanSummary({required String fromDate, required String toDate, String? line});
  Future<Either<Failure, ReportEntity>> getExpenseSummary({required String fromDate, required String toDate, String? line});
  Future<Either<Failure, ReportEntity>> getCompletedLoanSummary({required String fromDate, required String toDate, String? line});
  Future<Either<Failure, ReportEntity>> getBadLoanSummary({int minDays = 150, int maxDays = 999999, String? line});
  Future<Either<Failure, ReportEntity>> getMissingCustomerSummary({required String date, String? line});
  Future<Either<Failure, ReportEntity>> getInvestmentSummary({required String fromDate, required String toDate, String? line});
  Future<Either<Failure, ReportEntity>> getInvestmentExpenseSummary({required String fromDate, required String toDate});
  Future<Either<Failure, ReportEntity>> getLedgerReport({required String fromDate, required String toDate, String? lineId});
  Future<Either<Failure, ReportEntity>> getAboutToCloseLoanSummary({int withinDays = 30, String? line});
  Future<Either<Failure, ReportEntity>> getMonthlyInterestPendingSummary({required int month, required int year, String? line});
  Future<Either<Failure, ReportEntity>> getNonPerformanceLoanSummary({int minDays = 90, String? line});
  Future<Either<Failure, ReportEntity>> getNewBadLoanByDateSummary({required String fromDate, required String toDate, String? line});
  Future<Either<Failure, ReportEntity>> getLoanAnalysis({required String fromDate, required String toDate, String? line});
  Future<Either<Failure, ReportEntity>> getOnlineCollectionSummary({required String fromDate, required String toDate, String? line});
  Future<Either<Failure, ReportEntity>> getSiteDashboardSummary({required String date});
  Future<Either<Failure, ReportEntity>> getBookExcessLossSummary({required String fromDate, required String toDate});
}
