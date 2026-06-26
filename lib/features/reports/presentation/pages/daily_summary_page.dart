import 'package:vasooldrive/features/settings/presentation/bloc/settings_state.dart';
import 'package:vasooldrive/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/report_result_widget.dart';

class DailySummaryPage extends StatelessWidget {
  const DailySummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportBloc>(),
      child: const _DailySummaryView(),
    );
  }
}

class _DailySummaryView extends StatefulWidget {
  const _DailySummaryView();

  @override
  State<_DailySummaryView> createState() => _DailySummaryViewState();
}

class _DailySummaryViewState extends State<_DailySummaryView> {
  bool _isFiltersExpanded = true;

  String? _lineType;
  String? _line;
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
      LoadDailySummaryRequested(
        date: _dateController.text,
        lineType: _lineType,
        line: _line,
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.lightBlue, size: 20),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        List<String> _mockLineTypes = [];
        List<String> _mockLines = [];
        List<String> _mockAreas = [];
        
        if (settingsState is SettingsLoaded) {
          _mockLines = settingsState.lines.map((e) => e.name).toList();
          _mockLineTypes = settingsState.lines.map((e) => e.type).toSet().toList(); // Unique types
          _mockAreas = settingsState.areas.map((e) => e.name).toList();
        }
        
        return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Filter Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                CustomDropdownFormField<String>(
                  label: 'Line Type',
                  value: _lineType,
                  items: _mockLineTypes.map((String val) {
                    return DropdownMenuItem<String>(value: val, child: Text(val));
                  }).toList(),
                  onChanged: (val) => setState(() => _lineType = val),
                ),
                const SizedBox(height: 16),
                CustomDropdownFormField<String>(
                  label: 'Line',
                  value: _line,
                  items: _mockLines.map((String val) {
                    return DropdownMenuItem<String>(value: val, child: Text(val));
                  }).toList(),
                  onChanged: (val) => setState(() => _line = val),
                ),
                const SizedBox(height: 16),
                _buildDatePicker(label: 'Date', controller: _dateController),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    child: const Text('SUBMIT'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Results
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
