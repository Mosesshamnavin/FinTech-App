import 'package:vasooldrive/features/settings/presentation/bloc/settings_state.dart';
import 'package:vasooldrive/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_dropdown.dart';

class BadLoanSummaryPage extends StatefulWidget {
  const BadLoanSummaryPage({super.key});

  @override
  State<BadLoanSummaryPage> createState() => _BadLoanSummaryPageState();
}

class _BadLoanSummaryPageState extends State<BadLoanSummaryPage> {
  bool _isFiltersExpanded = true;

  String? _lineType;
  String? _line;
  bool _lineAll = true;
  String _selectedBadLoanDays = 'Above 150 Days';

  
  

  final TextEditingController _fromDaysController = TextEditingController();
  final TextEditingController _toDaysController = TextEditingController();

  @override
  void dispose() {
    _fromDaysController.dispose();
    _toDaysController.dispose();
    super.dispose();
  }

  Widget _buildRadioOption(String title) {
    return Column(
      children: [
        Row(
          children: [
            Radio<String>(
              value: title,
              groupValue: _selectedBadLoanDays,
              activeColor: Colors.lightBlue,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedBadLoanDays = value;
                  });
                }
              },
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        if (title != 'Custom')
          const Padding(
            padding: EdgeInsets.only(left: 48.0),
            child: Divider(height: 1, color: Colors.grey),
          ),
      ],
    );
  }

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
        title: const Text('Bad Loan Summary'),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomDropdownFormField<String>(
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
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _lineAll,
                      activeColor: Colors.lightBlue,
                      onChanged: (val) {
                        setState(() => _lineAll = val ?? false);
                      },
                    ),
                    const Text('All'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Bad Loan Days',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            _buildRadioOption('Above 100 Days'),
            _buildRadioOption('Above 150 Days'),
            _buildRadioOption('Between 150 to 200Days'),
            _buildRadioOption('Above 200 Days'),
            _buildRadioOption('Custom'),
            const Padding(
              padding: EdgeInsets.only(left: 48.0),
              child: Divider(height: 1, color: Colors.grey),
            ),
            if (_selectedBadLoanDays == 'Custom') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _fromDaysController,
                decoration: const InputDecoration(
                  labelText: 'From Days',
                  labelStyle: TextStyle(color: Colors.black87),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _toDaysController,
                decoration: const InputDecoration(
                  labelText: 'To Days',
                  labelStyle: TextStyle(color: Colors.black87),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
      },
    );
  }
}
