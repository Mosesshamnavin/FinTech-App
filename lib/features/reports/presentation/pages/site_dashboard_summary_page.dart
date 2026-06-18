import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_dropdown.dart';

class SiteDashboardSummaryPage extends StatefulWidget {
  const SiteDashboardSummaryPage({super.key});

  @override
  State<SiteDashboardSummaryPage> createState() => _SiteDashboardSummaryPageState();
}

class _SiteDashboardSummaryPageState extends State<SiteDashboardSummaryPage> {
  String? _lineType;
  
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final List<String> _mockLineTypes = ['Type A', 'Type B'];

  @override
  void initState() {
    super.initState();
    final today = _formatDate(DateTime.now());
    _fromDateController.text = today;
    _toDateController.text = today;
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

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            // Action for downloading excel
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'DOWNLOAD EXCEL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            // Action for downloading pdf
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'DOWNLOAD PDF',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            // Action for downloading comparision
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'DOWNLOAD COMPARISION',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Dashboard Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            _buildDatePicker(
              label: 'From Date',
              controller: _fromDateController,
            ),
            const SizedBox(height: 16),
            _buildDatePicker(
              label: 'To Date',
              controller: _toDateController,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }
}
