import 'package:flutter/material.dart';
import '../../domain/entities/report_entity.dart';

/// A reusable widget to display any report's results.
///
/// Shows a summary card at the top with key-value pairs,
/// followed by a horizontally scrollable data table.
class ReportResultWidget extends StatelessWidget {
  final ReportEntity report;

  const ReportResultWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            report.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Summary Card
        if (report.summaryFields.isNotEmpty)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: report.summaryFields.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          entry.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Data Table
        if (report.columns.isNotEmpty && report.rows.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateColor.resolveWith(
                    (states) => Colors.blue.shade50,
                  ),
                  columnSpacing: 24,
                  columns: report.columns.map((col) {
                    return DataColumn(
                      label: Text(
                        col,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  rows: report.rows.map((row) {
                    return DataRow(
                      cells: report.columns.map((col) {
                        final value = row[col] ?? '';
                        // Color-code status cells
                        Color? textColor;
                        if (col == 'Status') {
                          if (value == 'Paid') textColor = Colors.green;
                          if (value == 'Pending') textColor = Colors.orange;
                          if (value == 'Skipped') textColor = Colors.red;
                        }
                        return DataCell(
                          Text(
                            value,
                            style: textColor != null
                                ? TextStyle(color: textColor, fontWeight: FontWeight.bold)
                                : null,
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

        if (report.columns.isEmpty || report.rows.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No data available for this report.')),
          ),
      ],
    );
  }
}
