import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_dropdown.dart';

class LedgerReportPage extends StatefulWidget {
  const LedgerReportPage({super.key});

  @override
  State<LedgerReportPage> createState() => _LedgerReportPageState();
}

class _LedgerReportPageState extends State<LedgerReportPage> {
  String? _lineType;
  String? _line;
  String _orientation = 'Portrait';
  
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final List<String> _mockLineTypes = ['Type A', 'Type B'];
  final List<String> _mockLines = ['Line 1', 'Line 2'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    _fromDateController.text = _formatDate(firstDayOfMonth);
    _toDateController.text = _formatDate(now);
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

  Widget _buildDownloadButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Action for downloading
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CustomDropdownFormField<String>(
              label: 'Line Type',
              value: _lineType,
              items: _mockLineTypes.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _lineType = val);
              },
            ),
            const SizedBox(height: 16),
            CustomDropdownFormField<String>(
              label: 'Line',
              value: _line,
              items: _mockLines.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _line = val);
              },
            ),
            const SizedBox(height: 16),
            _buildDatePicker(
              label: 'From Date',
              controller: _fromDateController,
            ),
            const SizedBox(height: 16),
            _buildDatePicker(
              label: 'To Date',
              controller: _toDateController,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Portrait',
                        groupValue: _orientation,
                        activeColor: Colors.lightBlue,
                        onChanged: (val) {
                          if (val != null) setState(() => _orientation = val);
                        },
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 8.0, top: 12.0),
                            child: Text('Portrait', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Landscape',
                        groupValue: _orientation,
                        activeColor: Colors.lightBlue,
                        onChanged: (val) {
                          if (val != null) setState(() => _orientation = val);
                        },
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 8.0, top: 12.0),
                            child: Text('Landscape', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildDownloadButton('DOWNLOAD EXCEL'),
                  const SizedBox(height: 16),
                  _buildDownloadButton('DOWNLOAD PDF'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
