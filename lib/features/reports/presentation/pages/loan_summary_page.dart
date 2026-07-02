import 'package:vasooldrive/features/settings/presentation/bloc/settings_state.dart';
import 'package:vasooldrive/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../reports/presentation/bloc/report_bloc.dart';
import '../../../reports/presentation/bloc/report_event.dart';
import '../../../reports/presentation/bloc/report_state.dart';
import 'report_detail_page.dart';

class LoanSummaryPage extends StatefulWidget {
  const LoanSummaryPage({super.key});
  @override State<LoanSummaryPage> createState() => _LoanSummaryPageState();
}

class _LoanSummaryPageState extends State<LoanSummaryPage> {
  String? _line;
  bool _lineAll = true;
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  @override void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDateController.text = _fmt(DateTime(now.year, now.month, 1));
    _toDateController.text = _fmt(now);
  }

  @override void dispose() { _fromDateController.dispose(); _toDateController.dispose(); super.dispose(); }

  String _fmt(DateTime d) => "${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}";

  Future<void> _pickDate(TextEditingController c) async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) setState(() => c.text = _fmt(picked));
  }

  void _submit() {
    context.read<ReportBloc>().add(LoadLoanSummaryRequested(fromDate: _fromDateController.text, toDate: _toDateController.text, line: _lineAll ? null : _line));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportBloc>(),
      child: Builder(builder: (ctx) => BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportLoaded) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ReportDetailPage(report: state.report)));
          }
        },
        builder: (context, state) {
          return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, settingsState) {
            List<String> lines = settingsState is SettingsLoaded ? settingsState.lines.map((e) => e.name).toList() : [];
            return Scaffold(
              appBar: AppBar(title: const Text('Loan Summary'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context))),
              body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(child: CustomDropdownFormField<String>(label: 'Line', value: _line, items: lines.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() { _line = v; _lineAll = false; }))),
                  const SizedBox(width: 16),
                  Row(children: [Checkbox(value: _lineAll, activeColor: Colors.lightBlue, onChanged: (v) => setState(() { _lineAll = v ?? true; if (_lineAll) _line = null; })), const Text('All')]),
                ]),
                const SizedBox(height: 16),
                _datePicker('From Date', _fromDateController),
                const SizedBox(height: 16),
                _datePicker('To Date', _toDateController),
                const SizedBox(height: 32),
                Center(child: state is ReportLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[300], padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                if (state is ReportError) Padding(padding: const EdgeInsets.only(top: 16), child: Text(state.message, style: const TextStyle(color: Colors.red))),
              ])),
            );
          });
        },
      )),
    );
  }

  Widget _datePicker(String label, TextEditingController c) {
    return TextField(controller: c, readOnly: true, onTap: () => _pickDate(c), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.black54), floatingLabelBehavior: FloatingLabelBehavior.always, suffixIcon: const Icon(Icons.calendar_today, color: Colors.lightBlue, size: 20), border: const UnderlineInputBorder(), enabledBorder: const UnderlineInputBorder(), focusedBorder: const UnderlineInputBorder()));
  }
}
