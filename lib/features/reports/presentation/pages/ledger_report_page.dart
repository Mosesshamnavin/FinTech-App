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

class LedgerReportPage extends StatefulWidget {
  const LedgerReportPage({super.key});
  @override State<LedgerReportPage> createState() => _LedgerReportPageState();
}

class _LedgerReportPageState extends State<LedgerReportPage> {
  String? _line; 
  final TextEditingController _from = TextEditingController();
  final TextEditingController _to = TextEditingController();

  @override void initState() { super.initState(); final now = DateTime.now(); _from.text = _fmt(DateTime(now.year, now.month, 1)); _to.text = _fmt(now); }
  @override void dispose() { _from.dispose(); _to.dispose(); super.dispose(); }
  String _fmt(DateTime d) => "${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}";
  Future<void> _pick(TextEditingController c) async { final p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100)); if (p != null) setState(() => c.text = _fmt(p)); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportBloc>(),
      child: BlocConsumer<ReportBloc, ReportState>(
        listener: (ctx, state) { if (state is ReportLoaded) Navigator.push(ctx, MaterialPageRoute(builder: (_) => ReportDetailPage(report: state.report))); },
        builder: (ctx, state) => BlocBuilder<SettingsBloc, SettingsState>(builder: (context, ss) {
          List<String> lines = ss is SettingsLoaded ? ss.lines.map((e) => e.name).toList() : [];
          List<String?> lineIds = ss is SettingsLoaded ? [null, ...ss.lines.map((e) => e.id).toList()] : [null];
          List<String> lineNames = ss is SettingsLoaded ? ['All', ...ss.lines.map((e) => e.name).toList()] : ['All'];
          
          return Scaffold(
            appBar: AppBar(title: const Text('Ledger Report'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context))),
            body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              CustomDropdownFormField<String>(
                label: 'Line',
                value: _line,
                items: lines.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => _line = v),
              ),
              const SizedBox(height: 16),
              _dp('From Date', _from), const SizedBox(height: 16), _dp('To Date', _to),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: state is ReportLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
                onPressed: () {
                  String? selectedLineId;
                  if (_line != null) {
                    final idx = lineNames.indexOf(_line!);
                    if (idx > 0 && idx < lineIds.length) selectedLineId = lineIds[idx];
                  }
                  ctx.read<ReportBloc>().add(LoadLedgerReportRequested(fromDate: _from.text, toDate: _to.text, lineId: selectedLineId));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[300], padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('VIEW LEDGER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
              if (state is ReportError) Padding(padding: const EdgeInsets.only(top: 16), child: Text(state.message, style: const TextStyle(color: Colors.red))),
            ])),
          );
        }),
      ),
    );
  }

  Widget _dp(String label, TextEditingController c) => TextField(controller: c, readOnly: true, onTap: () => _pick(c), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.black54), floatingLabelBehavior: FloatingLabelBehavior.always, suffixIcon: const Icon(Icons.calendar_today, color: Colors.lightBlue, size: 20), border: const UnderlineInputBorder(), enabledBorder: const UnderlineInputBorder(), focusedBorder: const UnderlineInputBorder()));
}
