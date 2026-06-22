import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_daily_summary_usecase.dart';
import '../../domain/usecases/get_line_summary_usecase.dart';
import '../../domain/usecases/get_new_customer_summary_usecase.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetDailySummaryUseCase getDailySummaryUseCase;
  final GetLineSummaryUseCase getLineSummaryUseCase;
  final GetNewCustomerSummaryUseCase getNewCustomerSummaryUseCase;

  ReportBloc({
    required this.getDailySummaryUseCase,
    required this.getLineSummaryUseCase,
    required this.getNewCustomerSummaryUseCase,
  }) : super(const ReportInitial()) {
    on<LoadDailySummaryRequested>(_onLoadDailySummary);
    on<LoadLineSummaryRequested>(_onLoadLineSummary);
    on<LoadNewCustomerSummaryRequested>(_onLoadNewCustomerSummary);
  }

  Future<void> _onLoadDailySummary(
    LoadDailySummaryRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());
    final result = await getDailySummaryUseCase(
      DailySummaryParams(
        date: event.date,
        lineType: event.lineType,
        line: event.line,
      ),
    );
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) => emit(ReportLoaded(report)),
    );
  }

  Future<void> _onLoadLineSummary(
    LoadLineSummaryRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());
    final result = await getLineSummaryUseCase(
      LineSummaryParams(
        fromDate: event.fromDate,
        toDate: event.toDate,
        lineType: event.lineType,
        line: event.line,
        all: event.all,
      ),
    );
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) => emit(ReportLoaded(report)),
    );
  }

  Future<void> _onLoadNewCustomerSummary(
    LoadNewCustomerSummaryRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());
    final result = await getNewCustomerSummaryUseCase(
      NewCustomerSummaryParams(
        fromDate: event.fromDate,
        toDate: event.toDate,
        lineType: event.lineType,
        line: event.line,
        all: event.all,
      ),
    );
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) => emit(ReportLoaded(report)),
    );
  }
}
