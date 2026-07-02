import 'package:vasooldrive/features/settings/presentation/bloc/settings_state.dart';
import 'package:vasooldrive/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import 'report_detail_page.dart';

class BadLoanSummaryPage extends StatefulWidget {
  const BadLoanSummaryPage({super.key});
  @override State<BadLoanSummaryPage> createState() => _BadLoanSummaryPageState();
}

class _BadLoanSummaryPageState extends State<BadLoanSummaryPage> {
  String? _line; bool _lineAll = true;
  String _selectedBadLoanDays = 'Above 150 Days';
  final TextEditingController _fromDaysController = TextEditingController(text: '100');
  final TextEditingController _toDaysController = TextEditingController(text: '999');

  @override void dispose() { _fromDaysController.dispose(); _toDaysController.dispose(); super.dispose(); }

  (int, int) _getRange() {
    switch (_selectedBadLoanDays) {
      case 'Above 100 Days': return (100, 999999);
      case 'Above 150 Days': return (150, 999999);
      case 'Between 150 to 200Days': return (150, 200);
      case 'Above 200 Days': return (200, 999999);
      case 'Custom': return (int.tryParse(_fromDaysController.text) ?? 100, int.tryParse(_toDaysController.text) ?? 999999);
      default: return (150, 999999);
    }
  }

  Widget _radio(String title) => Column(children: [
    Row(children: [
      Radio<String>(value: title, groupValue: _selectedBadLoanDays, activeColor: Colors.lightBlue, onChanged: (v) { if (v != null) setState(() => _selectedBadLoanDays = v); }),
      Text(title, style: const TextStyle(fontSize: 16)),
    ]),
    if (title != 'Custom') const Padding(padding: EdgeInsets.only(left: 48), child: Divider(height: 1, color: Colors.grey)),
  ]);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportBloc>(),
      child: BlocConsumer<ReportBloc, ReportState>(
        listener: (ctx, state) { if (state is ReportLoaded) Navigator.push(ctx, MaterialPageRoute(builder: (_) => ReportDetailPage(report: state.report))); },
        builder: (ctx, state) => BlocBuilder<SettingsBloc, SettingsState>(builder: (context, ss) {
          List<String> lines = ss is SettingsLoaded ? ss.lines.map((e) => e.name).toList() : [];
          return Scaffold(
            appBar: AppBar(title: const Text('Bad Loan Summary'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context))),
            body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: CustomDropdownFormField<String>(label: 'Line', value: _line, items: lines.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() { _line = v; _lineAll = false; }))),
                const SizedBox(width: 16),
                Row(children: [Checkbox(value: _lineAll, activeColor: Colors.lightBlue, onChanged: (v) => setState(() { _lineAll = v ?? true; if (_lineAll) _line = null; })), const Text('All')]),
              ]),
              const SizedBox(height: 32),
              const Text('Bad Loan Days', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 8),
              _radio('Above 100 Days'), _radio('Above 150 Days'), _radio('Between 150 to 200Days'), _radio('Above 200 Days'), _radio('Custom'),
              const Padding(padding: EdgeInsets.only(left: 48), child: Divider(height: 1, color: Colors.grey)),
              if (_selectedBadLoanDays == 'Custom') ...[
                const SizedBox(height: 16),
                TextField(controller: _fromDaysController, decoration: const InputDecoration(labelText: 'From Days', border: UnderlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                TextField(controller: _toDaysController, decoration: const InputDecoration(labelText: 'To Days', border: UnderlineInputBorder()), keyboardType: TextInputType.number),
              ],
              const SizedBox(height: 32),
              Center(child: state is ReportLoading ? const CircularProgressIndicator() : ElevatedButton(
                onPressed: () { final (min, max) = _getRange(); ctx.read<ReportBloc>().add(LoadBadLoanSummaryRequested(minDays: min, maxDays: max, line: _lineAll ? null : _line)); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[300], padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
              if (state is ReportError) Padding(padding: const EdgeInsets.only(top: 16), child: Text(state.message, style: const TextStyle(color: Colors.red))),
            ])),
          );
        }),
      ),
    );
  }
}
