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

class MissingCustomerSummaryPage extends StatefulWidget {
  const MissingCustomerSummaryPage({super.key});
  @override State<MissingCustomerSummaryPage> createState() => _MissingCustomerSummaryPageState();
}
class _MissingCustomerSummaryPageState extends State<MissingCustomerSummaryPage> {
  String? _line; bool _lineAll = true;
  final TextEditingController _date = TextEditingController();
  @override void initState() { super.initState(); _date.text = _fmt(DateTime.now()); }
  @override void dispose() { _date.dispose(); super.dispose(); }
  String _fmt(DateTime d) => "${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}";
  Future<void> _pick() async { final p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100)); if (p != null) setState(() => _date.text = _fmt(p)); }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportBloc>(),
      child: BlocConsumer<ReportBloc, ReportState>(
        listener: (ctx, state) { if (state is ReportLoaded) Navigator.push(ctx, MaterialPageRoute(builder: (_) => ReportDetailPage(report: state.report))); },
        builder: (ctx, state) => BlocBuilder<SettingsBloc, SettingsState>(builder: (context, ss) {
          List<String> lines = ss is SettingsLoaded ? ss.lines.map((e) => e.name).toList() : [];
          return Scaffold(
            appBar: AppBar(title: const Text('Missing Customer Summary'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context))),
            body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: CustomDropdownFormField<String>(label: 'Line', value: _line, items: lines.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() { _line = v; _lineAll = false; }))),
                const SizedBox(width: 16),
                Row(children: [Checkbox(value: _lineAll, activeColor: Colors.lightBlue, onChanged: (v) => setState(() { _lineAll = v ?? true; if (_lineAll) _line = null; })), const Text('All')]),
              ]),
              const SizedBox(height: 16),
              TextField(controller: _date, readOnly: true, onTap: _pick, decoration: const InputDecoration(labelText: 'Date', labelStyle: TextStyle(color: Colors.black54), floatingLabelBehavior: FloatingLabelBehavior.always, suffixIcon: Icon(Icons.calendar_today, color: Colors.lightBlue, size: 20), border: UnderlineInputBorder(), enabledBorder: UnderlineInputBorder(), focusedBorder: UnderlineInputBorder())),
              const SizedBox(height: 32),
              Center(child: state is ReportLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: () => ctx.read<ReportBloc>().add(LoadMissingCustomerSummaryRequested(date: _date.text, line: _lineAll ? null : _line)), style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[300], padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              if (state is ReportError) Padding(padding: const EdgeInsets.only(top: 16), child: Text(state.message, style: const TextStyle(color: Colors.red))),
            ])),
          );
        }),
      ),
    );
  }
}
