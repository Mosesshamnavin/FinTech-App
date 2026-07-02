import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

// ─── Existing Use Cases ───────────────────────────────────────────────────────

class PlanReportParams { final String? line; const PlanReportParams({this.line}); }
class GetPlanReportUseCase { final ReportRepository repository; GetPlanReportUseCase(this.repository); Future<Either<Failure, ReportEntity>> call(PlanReportParams p) => repository.getPlanReport(line: p.line); }

class DailySummaryParams { final String date; final String? lineType, line; const DailySummaryParams({required this.date, this.lineType, this.line}); }
class GetDailySummaryUseCase { final ReportRepository repository; GetDailySummaryUseCase(this.repository); Future<Either<Failure, ReportEntity>> call(DailySummaryParams p) => repository.getDailySummary(date: p.date, lineType: p.lineType, line: p.line); }

class LineSummaryParams { final String fromDate, toDate; final String? lineType, line; final bool all; const LineSummaryParams({required this.fromDate, required this.toDate, this.lineType, this.line, this.all = true}); }
class GetLineSummaryUseCase { final ReportRepository repository; GetLineSummaryUseCase(this.repository); Future<Either<Failure, ReportEntity>> call(LineSummaryParams p) => repository.getLineSummary(fromDate: p.fromDate, toDate: p.toDate, lineType: p.lineType, line: p.line, all: p.all); }

class NewCustomerSummaryParams { final String fromDate, toDate; final String? lineType, line; final bool all; const NewCustomerSummaryParams({required this.fromDate, required this.toDate, this.lineType, this.line, this.all = true}); }
class GetNewCustomerSummaryUseCase { final ReportRepository repository; GetNewCustomerSummaryUseCase(this.repository); Future<Either<Failure, ReportEntity>> call(NewCustomerSummaryParams p) => repository.getNewCustomerSummary(fromDate: p.fromDate, toDate: p.toDate, lineType: p.lineType, line: p.line, all: p.all); }

// ─── New Use Cases ────────────────────────────────────────────────────────────

class DateRangeLineParams { final String fromDate, toDate; final String? line; const DateRangeLineParams({required this.fromDate, required this.toDate, this.line}); }
class GetLoanSummaryUseCase { final ReportRepository r; GetLoanSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(DateRangeLineParams p) => r.getLoanSummary(fromDate: p.fromDate, toDate: p.toDate, line: p.line); }
class GetExpenseSummaryUseCase { final ReportRepository r; GetExpenseSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(DateRangeLineParams p) => r.getExpenseSummary(fromDate: p.fromDate, toDate: p.toDate, line: p.line); }
class GetCompletedLoanSummaryUseCase { final ReportRepository r; GetCompletedLoanSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(DateRangeLineParams p) => r.getCompletedLoanSummary(fromDate: p.fromDate, toDate: p.toDate, line: p.line); }
class GetInvestmentSummaryUseCase { final ReportRepository r; GetInvestmentSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(DateRangeLineParams p) => r.getInvestmentSummary(fromDate: p.fromDate, toDate: p.toDate, line: p.line); }
class GetNewBadLoanByDateSummaryUseCase { final ReportRepository r; GetNewBadLoanByDateSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(DateRangeLineParams p) => r.getNewBadLoanByDateSummary(fromDate: p.fromDate, toDate: p.toDate, line: p.line); }
class GetLoanAnalysisUseCase { final ReportRepository r; GetLoanAnalysisUseCase(this.r); Future<Either<Failure, ReportEntity>> call(DateRangeLineParams p) => r.getLoanAnalysis(fromDate: p.fromDate, toDate: p.toDate, line: p.line); }
class GetOnlineCollectionSummaryUseCase { final ReportRepository r; GetOnlineCollectionSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(DateRangeLineParams p) => r.getOnlineCollectionSummary(fromDate: p.fromDate, toDate: p.toDate, line: p.line); }

class DateRangeParams { final String fromDate, toDate; const DateRangeParams({required this.fromDate, required this.toDate}); }
class GetInvestmentExpenseSummaryUseCase { final ReportRepository r; GetInvestmentExpenseSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(DateRangeParams p) => r.getInvestmentExpenseSummary(fromDate: p.fromDate, toDate: p.toDate); }
class GetBookExcessLossSummaryUseCase { final ReportRepository r; GetBookExcessLossSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(DateRangeParams p) => r.getBookExcessLossSummary(fromDate: p.fromDate, toDate: p.toDate); }

class LedgerParams { final String fromDate, toDate; final String? lineId; const LedgerParams({required this.fromDate, required this.toDate, this.lineId}); }
class GetLedgerReportUseCase { final ReportRepository r; GetLedgerReportUseCase(this.r); Future<Either<Failure, ReportEntity>> call(LedgerParams p) => r.getLedgerReport(fromDate: p.fromDate, toDate: p.toDate, lineId: p.lineId); }

class BadLoanParams { final int minDays, maxDays; final String? line; const BadLoanParams({this.minDays = 150, this.maxDays = 999999, this.line}); }
class GetBadLoanSummaryUseCase { final ReportRepository r; GetBadLoanSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(BadLoanParams p) => r.getBadLoanSummary(minDays: p.minDays, maxDays: p.maxDays, line: p.line); }

class MissingCustomerParams { final String date; final String? line; const MissingCustomerParams({required this.date, this.line}); }
class GetMissingCustomerSummaryUseCase { final ReportRepository r; GetMissingCustomerSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(MissingCustomerParams p) => r.getMissingCustomerSummary(date: p.date, line: p.line); }

class AboutToCloseParams { final int withinDays; final String? line; const AboutToCloseParams({this.withinDays = 30, this.line}); }
class GetAboutToCloseLoanSummaryUseCase { final ReportRepository r; GetAboutToCloseLoanSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(AboutToCloseParams p) => r.getAboutToCloseLoanSummary(withinDays: p.withinDays, line: p.line); }

class MonthlyInterestParams { final int month, year; final String? line; const MonthlyInterestParams({required this.month, required this.year, this.line}); }
class GetMonthlyInterestPendingSummaryUseCase { final ReportRepository r; GetMonthlyInterestPendingSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(MonthlyInterestParams p) => r.getMonthlyInterestPendingSummary(month: p.month, year: p.year, line: p.line); }

class NonPerformanceParams { final int minDays; final String? line; const NonPerformanceParams({this.minDays = 90, this.line}); }
class GetNonPerformanceLoanSummaryUseCase { final ReportRepository r; GetNonPerformanceLoanSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(NonPerformanceParams p) => r.getNonPerformanceLoanSummary(minDays: p.minDays, line: p.line); }

class SingleDateParams { final String date; const SingleDateParams({required this.date}); }
class GetSiteDashboardSummaryUseCase { final ReportRepository r; GetSiteDashboardSummaryUseCase(this.r); Future<Either<Failure, ReportEntity>> call(SingleDateParams p) => r.getSiteDashboardSummary(date: p.date); }
