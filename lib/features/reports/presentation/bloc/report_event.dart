import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override List<Object?> get props => [];
}

class LoadPlanReportRequested extends ReportEvent {
  final String? line;
  const LoadPlanReportRequested({this.line});
  @override List<Object?> get props => [line];
}

class LoadDailySummaryRequested extends ReportEvent {
  final String date; final String? lineType, line;
  const LoadDailySummaryRequested({required this.date, this.lineType, this.line});
  @override List<Object?> get props => [date, lineType, line];
}

class LoadLineSummaryRequested extends ReportEvent {
  final String fromDate, toDate; final String? lineType, line; final bool all;
  const LoadLineSummaryRequested({required this.fromDate, required this.toDate, this.lineType, this.line, this.all = true});
  @override List<Object?> get props => [fromDate, toDate, lineType, line, all];
}

class LoadNewCustomerSummaryRequested extends ReportEvent {
  final String fromDate, toDate; final String? lineType, line; final bool all;
  const LoadNewCustomerSummaryRequested({required this.fromDate, required this.toDate, this.lineType, this.line, this.all = true});
  @override List<Object?> get props => [fromDate, toDate, lineType, line, all];
}

class LoadLoanSummaryRequested extends ReportEvent {
  final String fromDate, toDate; final String? line;
  const LoadLoanSummaryRequested({required this.fromDate, required this.toDate, this.line});
  @override List<Object?> get props => [fromDate, toDate, line];
}

class LoadExpenseSummaryRequested extends ReportEvent {
  final String fromDate, toDate; final String? line;
  const LoadExpenseSummaryRequested({required this.fromDate, required this.toDate, this.line});
  @override List<Object?> get props => [fromDate, toDate, line];
}

class LoadCompletedLoanSummaryRequested extends ReportEvent {
  final String fromDate, toDate; final String? line;
  const LoadCompletedLoanSummaryRequested({required this.fromDate, required this.toDate, this.line});
  @override List<Object?> get props => [fromDate, toDate, line];
}

class LoadBadLoanSummaryRequested extends ReportEvent {
  final int minDays, maxDays; final String? line;
  const LoadBadLoanSummaryRequested({this.minDays = 150, this.maxDays = 999999, this.line});
  @override List<Object?> get props => [minDays, maxDays, line];
}

class LoadMissingCustomerSummaryRequested extends ReportEvent {
  final String date; final String? line;
  const LoadMissingCustomerSummaryRequested({required this.date, this.line});
  @override List<Object?> get props => [date, line];
}

class LoadInvestmentSummaryRequested extends ReportEvent {
  final String fromDate, toDate; final String? line;
  const LoadInvestmentSummaryRequested({required this.fromDate, required this.toDate, this.line});
  @override List<Object?> get props => [fromDate, toDate, line];
}

class LoadInvestmentExpenseSummaryRequested extends ReportEvent {
  final String fromDate, toDate;
  const LoadInvestmentExpenseSummaryRequested({required this.fromDate, required this.toDate});
  @override List<Object?> get props => [fromDate, toDate];
}

class LoadLedgerReportRequested extends ReportEvent {
  final String fromDate, toDate; final String? lineId;
  const LoadLedgerReportRequested({required this.fromDate, required this.toDate, this.lineId});
  @override List<Object?> get props => [fromDate, toDate, lineId];
}

class LoadAboutToCloseLoanSummaryRequested extends ReportEvent {
  final int withinDays; final String? line;
  const LoadAboutToCloseLoanSummaryRequested({this.withinDays = 30, this.line});
  @override List<Object?> get props => [withinDays, line];
}

class LoadMonthlyInterestPendingSummaryRequested extends ReportEvent {
  final int month, year; final String? line;
  const LoadMonthlyInterestPendingSummaryRequested({required this.month, required this.year, this.line});
  @override List<Object?> get props => [month, year, line];
}

class LoadNonPerformanceLoanSummaryRequested extends ReportEvent {
  final int minDays; final String? line;
  const LoadNonPerformanceLoanSummaryRequested({this.minDays = 90, this.line});
  @override List<Object?> get props => [minDays, line];
}

class LoadNewBadLoanByDateSummaryRequested extends ReportEvent {
  final String fromDate, toDate; final String? line;
  const LoadNewBadLoanByDateSummaryRequested({required this.fromDate, required this.toDate, this.line});
  @override List<Object?> get props => [fromDate, toDate, line];
}

class LoadLoanAnalysisRequested extends ReportEvent {
  final String fromDate, toDate; final String? line;
  const LoadLoanAnalysisRequested({required this.fromDate, required this.toDate, this.line});
  @override List<Object?> get props => [fromDate, toDate, line];
}

class LoadOnlineCollectionSummaryRequested extends ReportEvent {
  final String fromDate, toDate; final String? line;
  const LoadOnlineCollectionSummaryRequested({required this.fromDate, required this.toDate, this.line});
  @override List<Object?> get props => [fromDate, toDate, line];
}

class LoadSiteDashboardSummaryRequested extends ReportEvent {
  final String date;
  const LoadSiteDashboardSummaryRequested({required this.date});
  @override List<Object?> get props => [date];
}

class LoadBookExcessLossSummaryRequested extends ReportEvent {
  final String fromDate, toDate;
  const LoadBookExcessLossSummaryRequested({required this.fromDate, required this.toDate});
  @override List<Object?> get props => [fromDate, toDate];
}
