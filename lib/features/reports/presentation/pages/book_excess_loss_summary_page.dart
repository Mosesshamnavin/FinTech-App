import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import 'report_detail_page.dart';

class BookExcessLossSummaryPage extends StatefulWidget {
  const BookExcessLossSummaryPage({super.key});
  @override State<BookExcessLossSummaryPage> createState() => _BookExcessLossSummaryPageState();
}
class _BookExcessLossSummaryPageState extends State<BookExcessLossSummaryPage> {
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
        builder: (ctx, state) => Scaffold(
          appBar: AppBar(title: const Text('Book Excess/Loss Summary'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context))),
          body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            _dp('From Date', _from), const SizedBox(height: 16), _dp('To Date', _to),
            const SizedBox(height: 32),
            Center(child: state is ReportLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: () => ctx.read<ReportBloc>().add(LoadBookExcessLossSummaryRequested(fromDate: _from.text, toDate: _to.text)), style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[300], padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            if (state is ReportError) Padding(padding: const EdgeInsets.only(top: 16), child: Text(state.message, style: const TextStyle(color: Colors.red))),
          ])),
        ),
      ),
    );
  }
  Widget _dp(String label, TextEditingController c) => TextField(controller: c, readOnly: true, onTap: () => _pick(c), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.black54), floatingLabelBehavior: FloatingLabelBehavior.always, suffixIcon: const Icon(Icons.calendar_today, color: Colors.lightBlue, size: 20), border: const UnderlineInputBorder(), enabledBorder: const UnderlineInputBorder(), focusedBorder: const UnderlineInputBorder()));
}
