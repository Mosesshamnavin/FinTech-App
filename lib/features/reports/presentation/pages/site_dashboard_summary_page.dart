import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

class SiteDashboardSummaryPage extends StatelessWidget {
  const SiteDashboardSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportBloc>(),
      child: const _SiteDashboardSummaryView(),
    );
  }
}

class _SiteDashboardSummaryView extends StatefulWidget {
  const _SiteDashboardSummaryView();

  @override
  State<_SiteDashboardSummaryView> createState() => _SiteDashboardSummaryViewState();
}

class _SiteDashboardSummaryViewState extends State<_SiteDashboardSummaryView> {
  bool _isFiltersExpanded = true;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _onSubmit() {
    setState(() { _isFiltersExpanded = false; });
    context.read<ReportBloc>().add(
      LoadSiteDashboardSummaryRequested(
        date: _dateController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Dashboard Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          if (!_isFiltersExpanded)
            ListTile(
              title: const Text('Edit Filters', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue)),
              trailing: const Icon(Icons.edit, color: Colors.lightBlue, size: 20),
              onTap: () => setState(() => _isFiltersExpanded = true),
            ),
          if (_isFiltersExpanded)
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: const InputDecoration(
                      labelText: 'Select Date',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: Icon(Icons.calendar_today, color: Colors.lightBlue, size: 20),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[300],
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'VIEW DASHBOARD',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          Expanded(
            child: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state is ReportInitial) {
                  return const Center(child: Text('Select filters and tap VIEW DASHBOARD.'));
                } else if (state is ReportLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReportError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                } else if (state is ReportLoaded) {
                  final report = state.report;
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          report.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...report.rows.map((row) {
                        final metric = row['Metric'] ?? '';
                        final val = row['Value'] ?? '—';
                        final amt = row['Amount'] ?? '—';

                        IconData icon;
                        Color color;
                        String subtitleText = '';

                        if (metric.contains('Collection')) {
                          icon = Icons.monetization_on;
                          color = Colors.green;
                          subtitleText = val != '—' ? '$val transaction(s)' : '';
                        } else if (metric.contains('Expense')) {
                          icon = Icons.trending_down;
                          color = Colors.red;
                          subtitleText = 'Today\'s outgoings';
                        } else if (metric.contains('Loan')) {
                          icon = Icons.assignment;
                          color = Colors.blue;
                          subtitleText = val != '—' ? '$val active loan(s)' : '';
                        } else if (metric.contains('Outstanding')) {
                          icon = Icons.account_balance_wallet;
                          color = Colors.orange;
                          subtitleText = 'Total remaining balance';
                        } else {
                          icon = Icons.people;
                          color = Colors.teal;
                          subtitleText = val != '—' ? '$val registered customer(s)' : '';
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: color.withOpacity(0.1),
                                child: Icon(icon, color: color, size: 24),
                              ),
                              title: Text(
                                metric,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: subtitleText.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        subtitleText,
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                    )
                                  : null,
                              trailing: amt != '—'
                                  ? Text(
                                      amt,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: color == Colors.red ? Colors.red.shade700 : Colors.black87,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
