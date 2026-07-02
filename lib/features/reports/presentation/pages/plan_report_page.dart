import 'package:vasooldrive/features/settings/presentation/bloc/settings_state.dart';
import 'package:vasooldrive/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/report_result_widget.dart';

class PlanReportPage extends StatelessWidget {
  const PlanReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportBloc>(),
      child: const _PlanReportView(),
    );
  }
}

class _PlanReportView extends StatefulWidget {
  const _PlanReportView();

  @override
  State<_PlanReportView> createState() => _PlanReportViewState();
}

class _PlanReportViewState extends State<_PlanReportView> {
  bool _isFiltersExpanded = true;
  String? _line;
  bool _lineAll = true;

  void _onSubmit() {
    setState(() { _isFiltersExpanded = false; });
    context.read<ReportBloc>().add(
      LoadPlanReportRequested(
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
            title: const Text('Collection Plan'),
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
