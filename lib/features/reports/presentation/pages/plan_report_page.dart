import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_dropdown.dart';

class PlanReportPage extends StatefulWidget {
  const PlanReportPage({super.key});

  @override
  State<PlanReportPage> createState() => _PlanReportPageState();
}

class _PlanReportPageState extends State<PlanReportPage> {
  // Common state
  String? _dateLineType;
  String? _dateLine;
  bool _dateLineAll = true;
  
  String? _lineTabLineType;
  String? _lineTabLine;
  
  String? _allTabLine;
  bool _allTabLineAll = true;

  final TextEditingController _dateFromDateController = TextEditingController();
  final TextEditingController _dateToDateController = TextEditingController();
  final TextEditingController _lineDateController = TextEditingController();
  final TextEditingController _allFromDateController = TextEditingController();
  final TextEditingController _allToDateController = TextEditingController();

  final List<String> _mockLineTypes = ['Type A', 'Type B'];
  final List<String> _mockLines = ['Line 1', 'Line 2'];

  @override
  void initState() {
    super.initState();
    // Initialize dates to today
    final today = _formatDate(DateTime.now());
    _dateFromDateController.text = today;
    _dateToDateController.text = today;
    _lineDateController.text = today;
    _allFromDateController.text = today;
    _allToDateController.text = today;
  }

  @override
  void dispose() {
    _dateFromDateController.dispose();
    _dateToDateController.dispose();
    _lineDateController.dispose();
    _allFromDateController.dispose();
    _allToDateController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plan'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            tabs: [
              Tab(text: 'DATE'),
              Tab(text: 'LINE'),
              Tab(text: 'ALL'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDateTab(),
            _buildLineTab(),
            _buildAllTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return CustomDropdownFormField<String>(
      label: label,
      value: value,
      items: items.map((String val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val),
        );
      }).toList(),
      onChanged: onChanged,
    );
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

  Widget _buildViewButton() {
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
          'VIEW',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Line Type',
            value: _dateLineType,
            items: _mockLineTypes,
            onChanged: (val) {
              setState(() => _dateLineType = val);
            },
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Line',
                  value: _dateLine,
                  items: _mockLines,
                  onChanged: (val) {
                    setState(() => _dateLine = val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Checkbox(
                    value: _dateLineAll,
                    activeColor: Colors.lightBlue,
                    onChanged: (val) {
                      setState(() => _dateLineAll = val ?? false);
                    },
                  ),
                  const Text('All'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDatePicker(
            label: 'From Date',
            controller: _dateFromDateController,
          ),
          const SizedBox(height: 16),
          _buildDatePicker(
            label: 'To Date',
            controller: _dateToDateController,
          ),
          const SizedBox(height: 32),
          _buildViewButton(),
        ],
      ),
    );
  }

  Widget _buildLineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Line Type',
            value: _lineTabLineType,
            items: _mockLineTypes,
            onChanged: (val) {
              setState(() => _lineTabLineType = val);
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Line',
            value: _lineTabLine,
            items: _mockLines,
            onChanged: (val) {
              setState(() => _lineTabLine = val);
            },
          ),
          const SizedBox(height: 16),
          _buildDatePicker(
            label: 'Date',
            controller: _lineDateController,
          ),
          const SizedBox(height: 32),
          _buildViewButton(),
        ],
      ),
    );
  }

  Widget _buildAllTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Line',
                  value: _allTabLine,
                  items: _mockLines,
                  onChanged: (val) {
                    setState(() => _allTabLine = val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Checkbox(
                    value: _allTabLineAll,
                    activeColor: Colors.lightBlue,
                    onChanged: (val) {
                      setState(() => _allTabLineAll = val ?? false);
                    },
                  ),
                  const Text('All'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDatePicker(
            label: 'From Date',
            controller: _allFromDateController,
          ),
          const SizedBox(height: 16),
          _buildDatePicker(
            label: 'To Date',
            controller: _allToDateController,
          ),
          const SizedBox(height: 32),
          _buildViewButton(),
        ],
      ),
    );
  }
}
