import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailySummaryRequested extends ReportEvent {
  final String date;
  final String? lineType;
  final String? line;

  const LoadDailySummaryRequested({
    required this.date,
    this.lineType,
    this.line,
  });

  @override
  List<Object?> get props => [date, lineType, line];
}

class LoadLineSummaryRequested extends ReportEvent {
  final String fromDate;
  final String toDate;
  final String? lineType;
  final String? line;
  final bool all;

  const LoadLineSummaryRequested({
    required this.fromDate,
    required this.toDate,
    this.lineType,
    this.line,
    this.all = true,
  });

  @override
  List<Object?> get props => [fromDate, toDate, lineType, line, all];
}

class LoadNewCustomerSummaryRequested extends ReportEvent {
  final String fromDate;
  final String toDate;
  final String? lineType;
  final String? line;
  final bool all;

  const LoadNewCustomerSummaryRequested({
    required this.fromDate,
    required this.toDate,
    this.lineType,
    this.line,
    this.all = true,
  });

  @override
  List<Object?> get props => [fromDate, toDate, lineType, line, all];
}
