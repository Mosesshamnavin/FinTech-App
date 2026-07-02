import '../../domain/entities/report_entity.dart';

abstract class ReportRemoteDataSource {
  Future<ReportEntity> getPlanReport({String? line});
  Future<ReportEntity> getDailySummary({required String date, String? lineType, String? line});
  Future<ReportEntity> getLineSummary({required String fromDate, required String toDate, String? lineType, String? line, bool all = true});
  Future<ReportEntity> getNewCustomerSummary({required String fromDate, required String toDate, String? lineType, String? line, bool all = true});
  Future<ReportEntity> getLoanSummary({required String fromDate, required String toDate, String? line});
  Future<ReportEntity> getExpenseSummary({required String fromDate, required String toDate, String? line});
  Future<ReportEntity> getCompletedLoanSummary({required String fromDate, required String toDate, String? line});
  Future<ReportEntity> getBadLoanSummary({int minDays = 150, int maxDays = 999999, String? line});
  Future<ReportEntity> getMissingCustomerSummary({required String date, String? line});
  Future<ReportEntity> getInvestmentSummary({required String fromDate, required String toDate, String? line});
  Future<ReportEntity> getInvestmentExpenseSummary({required String fromDate, required String toDate});
  Future<ReportEntity> getLedgerReport({required String fromDate, required String toDate, String? lineId});
  Future<ReportEntity> getAboutToCloseLoanSummary({int withinDays = 30, String? line});
  Future<ReportEntity> getMonthlyInterestPendingSummary({required int month, required int year, String? line});
  Future<ReportEntity> getNonPerformanceLoanSummary({int minDays = 90, String? line});
  Future<ReportEntity> getNewBadLoanByDateSummary({required String fromDate, required String toDate, String? line});
  Future<ReportEntity> getLoanAnalysis({required String fromDate, required String toDate, String? line});
  Future<ReportEntity> getOnlineCollectionSummary({required String fromDate, required String toDate, String? line});
  Future<ReportEntity> getSiteDashboardSummary({required String date});
  Future<ReportEntity> getBookExcessLossSummary({required String fromDate, required String toDate});
}
