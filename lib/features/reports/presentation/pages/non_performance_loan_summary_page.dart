import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_dropdown.dart';

class NonPerformanceLoanSummaryPage extends StatefulWidget {
  const NonPerformanceLoanSummaryPage({super.key});

  @override
  State<NonPerformanceLoanSummaryPage> createState() => _NonPerformanceLoanSummaryPageState();
}

class _NonPerformanceLoanSummaryPageState extends State<NonPerformanceLoanSummaryPage> {
  String? _lineType;
  String? _line;
  bool _showExactDays = false;

  final List<String> _mockLineTypes = ['Type A', 'Type B'];
  final List<String> _mockLines = ['Line 1', 'Line 2'];

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Action for viewing report
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text(
          'SUBMIT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Non Performance Loan Summary'),
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
            // The empty underline space in the screenshot
            const TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Show Exact Days',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _showExactDays,
                  onChanged: (val) {
                    setState(() {
                      _showExactDays = val;
                    });
                  },
                  activeColor: Colors.lightBlue,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}
