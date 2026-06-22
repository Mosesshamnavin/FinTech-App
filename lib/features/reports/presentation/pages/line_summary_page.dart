import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/report_result_widget.dart';

class LineSummaryPage extends StatelessWidget {
  const LineSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportBloc>(),
      child: const _LineSummaryView(),
    );
  }
}

class _LineSummaryView extends StatefulWidget {
  const _LineSummaryView();

  @override
  State<_LineSummaryView> createState() => _LineSummaryViewState();
}

class _LineSummaryViewState extends State<_LineSummaryView> {
  String? _lineType;
  String? _line;
  bool _lineAll = true;

  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final List<String> _mockLineTypes = ['Type A', 'Type B'];
  final List<String> _mockLines = ['Line 1', 'Line 2'];

  @override
  void initState() {
    super.initState();
    final today = _formatDate(DateTime.now());
    _fromDateController.text = today;
    _toDateController.text = today;
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = _formatDate(picked);
      });
    }
  }

  void _onSubmit() {
    context.read<ReportBloc>().add(
      LoadLineSummaryRequested(
        fromDate: _fromDateController.text,
        toDate: _toDateController.text,
        lineType: _lineType,
        line: _line,
        all: _lineAll,
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
      onTap: () => _selectDate(context, controller),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.lightBlue, size: 20),
        border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Line Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CustomDropdownFormField<String>(
                        label: 'Line',
                        value: _line,
                        items: _mockLines.map((String val) {
                          return DropdownMenuItem<String>(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) => setState(() => _line = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _lineAll,
                          activeColor: Colors.lightBlue,
                          onChanged: (val) => setState(() => _lineAll = val ?? false),
                        ),
                        const Text('All'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDatePicker(label: 'From Date', controller: _fromDateController),
                const SizedBox(height: 16),
                _buildDatePicker(label: 'To Date', controller: _toDateController),
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
  }
}
