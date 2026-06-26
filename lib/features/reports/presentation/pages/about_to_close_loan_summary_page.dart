import 'package:vasooldrive/features/settings/presentation/bloc/settings_state.dart';
import 'package:vasooldrive/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_dropdown.dart';

class AboutToCloseLoanSummaryPage extends StatefulWidget {
  const AboutToCloseLoanSummaryPage({super.key});

  @override
  State<AboutToCloseLoanSummaryPage> createState() => _AboutToCloseLoanSummaryPageState();
}

class _AboutToCloseLoanSummaryPageState extends State<AboutToCloseLoanSummaryPage> {
  bool _isFiltersExpanded = true;

  String? _lineType;
  String? _line;

  
  

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
      },
    );
  }
}
