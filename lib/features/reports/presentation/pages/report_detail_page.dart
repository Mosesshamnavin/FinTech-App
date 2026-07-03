import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../domain/entities/report_entity.dart';

class ReportDetailPage extends StatefulWidget {
  final ReportEntity report;
  const ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final filteredRows = report.rows.where((row) {
      if (_searchQuery.isEmpty) return true;
      return row.values.any((v) => v.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(report.title, style: const TextStyle(fontSize: 16)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // Summary Card
          if (report.summaryFields.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.primaryContainer)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Divider(height: 12),
                  Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    children: report.summaryFields.entries.map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(153), fontSize: 12)),
                        Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    )).toList(),
                  ),
                ],
              ),
            ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                prefixIcon: const Padding(padding: EdgeInsets.only(left: 12, right: 8), child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16, color: Colors.grey)),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          // Data Table
          Expanded(
            child: filteredRows.isEmpty
              ? const Center(child: Text('No data found.', style: TextStyle(color: Colors.grey)))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primaryContainer),
                      columnSpacing: 38,
                      dataRowMinHeight: 44,
                      dataRowMaxHeight: 56,
                      columns: report.columns.map((col) => DataColumn(
                        label: Text(col, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                      )).toList(),
                      rows: filteredRows.map((row) => DataRow(
                        cells: report.columns.map((col) => DataCell(
                          Text(row[col] ?? '', style: const TextStyle(fontSize: 13)),
                        )).toList(),
                      )).toList(),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
