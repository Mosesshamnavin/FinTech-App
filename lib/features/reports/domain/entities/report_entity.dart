import 'package:equatable/equatable.dart';

/// A generic report entity that can represent any tabular report.
///
/// [title] — The report's display title (e.g., "Daily Summary for 22/06/2026").
/// [summaryFields] — Key-value pairs for the summary card at the top
///                    (e.g., {"Total Collected": "₹15,000", "Pending": "₹3,000"}).
/// [columns] — Column headers for the data table.
/// [rows] — Each row is a Map of column-name → value.
class ReportEntity extends Equatable {
  final String title;
  final Map<String, String> summaryFields;
  final List<String> columns;
  final List<Map<String, String>> rows;

  const ReportEntity({
    required this.title,
    required this.summaryFields,
    required this.columns,
    required this.rows,
  });

  @override
  List<Object> get props => [title, summaryFields, columns, rows];
}
