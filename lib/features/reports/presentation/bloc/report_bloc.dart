import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_daily_summary_usecase.dart';
import '../../domain/usecases/get_line_summary_usecase.dart';
import '../../domain/usecases/get_new_customer_summary_usecase.dart';
import '../../domain/usecases/report_usecases.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetPlanReportUseCase getPlanReportUseCase;
  final GetDailySummaryUseCase getDailySummaryUseCase;
  final GetLineSummaryUseCase getLineSummaryUseCase;
  final GetNewCustomerSummaryUseCase getNewCustomerSummaryUseCase;
  final GetLoanSummaryUseCase getLoanSummaryUseCase;
  final GetExpenseSummaryUseCase getExpenseSummaryUseCase;
  final GetCompletedLoanSummaryUseCase getCompletedLoanSummaryUseCase;
  final GetBadLoanSummaryUseCase getBadLoanSummaryUseCase;
  final GetMissingCustomerSummaryUseCase getMissingCustomerSummaryUseCase;
  final GetInvestmentSummaryUseCase getInvestmentSummaryUseCase;
  final GetInvestmentExpenseSummaryUseCase getInvestmentExpenseSummaryUseCase;
  final GetLedgerReportUseCase getLedgerReportUseCase;
  final GetAboutToCloseLoanSummaryUseCase getAboutToCloseLoanSummaryUseCase;
  final GetMonthlyInterestPendingSummaryUseCase getMonthlyInterestPendingSummaryUseCase;
  final GetNonPerformanceLoanSummaryUseCase getNonPerformanceLoanSummaryUseCase;
  final GetNewBadLoanByDateSummaryUseCase getNewBadLoanByDateSummaryUseCase;
  final GetLoanAnalysisUseCase getLoanAnalysisUseCase;
  final GetOnlineCollectionSummaryUseCase getOnlineCollectionSummaryUseCase;
  final GetSiteDashboardSummaryUseCase getSiteDashboardSummaryUseCase;
  final GetBookExcessLossSummaryUseCase getBookExcessLossSummaryUseCase;

  ReportBloc({
    required this.getPlanReportUseCase,
    required this.getDailySummaryUseCase,
    required this.getLineSummaryUseCase,
    required this.getNewCustomerSummaryUseCase,
    required this.getLoanSummaryUseCase,
    required this.getExpenseSummaryUseCase,
    required this.getCompletedLoanSummaryUseCase,
    required this.getBadLoanSummaryUseCase,
    required this.getMissingCustomerSummaryUseCase,
    required this.getInvestmentSummaryUseCase,
    required this.getInvestmentExpenseSummaryUseCase,
    required this.getLedgerReportUseCase,
    required this.getAboutToCloseLoanSummaryUseCase,
    required this.getMonthlyInterestPendingSummaryUseCase,
    required this.getNonPerformanceLoanSummaryUseCase,
    required this.getNewBadLoanByDateSummaryUseCase,
    required this.getLoanAnalysisUseCase,
    required this.getOnlineCollectionSummaryUseCase,
    required this.getSiteDashboardSummaryUseCase,
    required this.getBookExcessLossSummaryUseCase,
  }) : super(const ReportInitial()) {
    on<LoadPlanReportRequested>(_onLoadPlanReport);
    on<LoadDailySummaryRequested>(_onLoadDailySummary);
    on<LoadLineSummaryRequested>(_onLoadLineSummary);
    on<LoadNewCustomerSummaryRequested>(_onLoadNewCustomerSummary);
    on<LoadLoanSummaryRequested>(_onLoadLoanSummary);
    on<LoadExpenseSummaryRequested>(_onLoadExpenseSummary);
    on<LoadCompletedLoanSummaryRequested>(_onLoadCompletedLoanSummary);
    on<LoadBadLoanSummaryRequested>(_onLoadBadLoanSummary);
    on<LoadMissingCustomerSummaryRequested>(_onLoadMissingCustomerSummary);
    on<LoadInvestmentSummaryRequested>(_onLoadInvestmentSummary);
    on<LoadInvestmentExpenseSummaryRequested>(_onLoadInvestmentExpenseSummary);
    on<LoadLedgerReportRequested>(_onLoadLedgerReport);
    on<LoadAboutToCloseLoanSummaryRequested>(_onLoadAboutToCloseLoanSummary);
    on<LoadMonthlyInterestPendingSummaryRequested>(_onLoadMonthlyInterestPendingSummary);
    on<LoadNonPerformanceLoanSummaryRequested>(_onLoadNonPerformanceLoanSummary);
    on<LoadNewBadLoanByDateSummaryRequested>(_onLoadNewBadLoanByDateSummary);
    on<LoadLoanAnalysisRequested>(_onLoadLoanAnalysis);
    on<LoadOnlineCollectionSummaryRequested>(_onLoadOnlineCollectionSummary);
    on<LoadSiteDashboardSummaryRequested>(_onLoadSiteDashboardSummary);
    on<LoadBookExcessLossSummaryRequested>(_onLoadBookExcessLossSummary);
  }

  Future<void> _onLoadPlanReport(LoadPlanReportRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getPlanReportUseCase(PlanReportParams(line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadDailySummary(LoadDailySummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getDailySummaryUseCase(DailySummaryParams(date: event.date, lineType: event.lineType, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadLineSummary(LoadLineSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getLineSummaryUseCase(LineSummaryParams(fromDate: event.fromDate, toDate: event.toDate, lineType: event.lineType, line: event.line, all: event.all));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadNewCustomerSummary(LoadNewCustomerSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getNewCustomerSummaryUseCase(NewCustomerSummaryParams(fromDate: event.fromDate, toDate: event.toDate, lineType: event.lineType, line: event.line, all: event.all));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadLoanSummary(LoadLoanSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getLoanSummaryUseCase(DateRangeLineParams(fromDate: event.fromDate, toDate: event.toDate, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadExpenseSummary(LoadExpenseSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getExpenseSummaryUseCase(DateRangeLineParams(fromDate: event.fromDate, toDate: event.toDate, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadCompletedLoanSummary(LoadCompletedLoanSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getCompletedLoanSummaryUseCase(DateRangeLineParams(fromDate: event.fromDate, toDate: event.toDate, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadBadLoanSummary(LoadBadLoanSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getBadLoanSummaryUseCase(BadLoanParams(minDays: event.minDays, maxDays: event.maxDays, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadMissingCustomerSummary(LoadMissingCustomerSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getMissingCustomerSummaryUseCase(MissingCustomerParams(date: event.date, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadInvestmentSummary(LoadInvestmentSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getInvestmentSummaryUseCase(DateRangeLineParams(fromDate: event.fromDate, toDate: event.toDate, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadInvestmentExpenseSummary(LoadInvestmentExpenseSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getInvestmentExpenseSummaryUseCase(DateRangeParams(fromDate: event.fromDate, toDate: event.toDate));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadLedgerReport(LoadLedgerReportRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getLedgerReportUseCase(LedgerParams(fromDate: event.fromDate, toDate: event.toDate, lineId: event.lineId));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadAboutToCloseLoanSummary(LoadAboutToCloseLoanSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getAboutToCloseLoanSummaryUseCase(AboutToCloseParams(withinDays: event.withinDays, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadMonthlyInterestPendingSummary(LoadMonthlyInterestPendingSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getMonthlyInterestPendingSummaryUseCase(MonthlyInterestParams(month: event.month, year: event.year, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadNonPerformanceLoanSummary(LoadNonPerformanceLoanSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getNonPerformanceLoanSummaryUseCase(NonPerformanceParams(minDays: event.minDays, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadNewBadLoanByDateSummary(LoadNewBadLoanByDateSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getNewBadLoanByDateSummaryUseCase(DateRangeLineParams(fromDate: event.fromDate, toDate: event.toDate, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadLoanAnalysis(LoadLoanAnalysisRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getLoanAnalysisUseCase(DateRangeLineParams(fromDate: event.fromDate, toDate: event.toDate, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadOnlineCollectionSummary(LoadOnlineCollectionSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getOnlineCollectionSummaryUseCase(DateRangeLineParams(fromDate: event.fromDate, toDate: event.toDate, line: event.line));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadSiteDashboardSummary(LoadSiteDashboardSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getSiteDashboardSummaryUseCase(SingleDateParams(date: event.date));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }

  Future<void> _onLoadBookExcessLossSummary(LoadBookExcessLossSummaryRequested event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    final result = await getBookExcessLossSummaryUseCase(DateRangeParams(fromDate: event.fromDate, toDate: event.toDate));
    result.fold((f) => emit(ReportError(f.message)), (r) => emit(ReportLoaded(r)));
  }
}
