import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_dropdown.dart';

class AboutToCloseLoanSummaryPage extends StatefulWidget {
  const AboutToCloseLoanSummaryPage({super.key});

  @override
  State<AboutToCloseLoanSummaryPage> createState() => _AboutToCloseLoanSummaryPageState();
}

class _AboutToCloseLoanSummaryPageState extends State<AboutToCloseLoanSummaryPage> {
  String? _lineType;
  String? _line;

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
        title: const Text('About to Close Loan Summary'),
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
            const SizedBox(height: 64),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}
