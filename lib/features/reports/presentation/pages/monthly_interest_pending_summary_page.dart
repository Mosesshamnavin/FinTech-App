import 'package:vasooldrive/features/settings/presentation/bloc/settings_state.dart';
import 'package:vasooldrive/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/report_result_widget.dart';

class MonthlyInterestPendingSummaryPage extends StatelessWidget {
  const MonthlyInterestPendingSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportBloc>(),
      child: const _MonthlyInterestPendingSummaryView(),
    );
  }
}

class _MonthlyInterestPendingSummaryView extends StatefulWidget {
  const _MonthlyInterestPendingSummaryView();

  @override
  State<_MonthlyInterestPendingSummaryView> createState() => _MonthlyInterestPendingSummaryViewState();
}

class _MonthlyInterestPendingSummaryViewState extends State<_MonthlyInterestPendingSummaryView> {
  bool _isFiltersExpanded = true;
  String? _line;
  bool _lineAll = true;
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
    final parsed = DateFormat('dd/MM/yyyy').parse(_dateController.text);
    context.read<ReportBloc>().add(
      LoadMonthlyInterestPendingSummaryRequested(
        month: parsed.month,
        year: parsed.year,
        line: _lineAll ? null : _line,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        List<String> mockLines = [];
        if (settingsState is SettingsLoaded) {
          mockLines = settingsState.lines.map((e) => e.name).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Monthly Interest Pending Summary'),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: CustomDropdownFormField<String>(
                              label: 'Line',
                              value: _line,
                              items: mockLines.map((String val) {
                                return DropdownMenuItem<String>(value: val, child: Text(val));
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _line = val;
                                  if (val != null) _lineAll = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _lineAll,
                                activeColor: Colors.lightBlue,
                                onChanged: (val) {
                                  setState(() {
                                    _lineAll = val ?? false;
                                    if (_lineAll) _line = null;
                                  });
                                },
                              ),
                              const Text('All'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: const InputDecoration(
                          labelText: 'Select Month & Year (from Date)',
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
                            'SUBMIT',
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
                      return const Center(child: Text('Select filters and tap SUBMIT.'));
                    } else if (state is ReportLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ReportError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                    } else if (state is ReportLoaded) {
                      return ReportResultWidget(report: state.report);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
