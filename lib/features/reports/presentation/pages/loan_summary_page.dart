import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../loans/presentation/bloc/loans_bloc.dart';
import '../../../loans/presentation/bloc/loans_event.dart';
import '../../../loans/presentation/bloc/loans_state.dart';

class LoanSummaryPage extends StatefulWidget {
  const LoanSummaryPage({super.key});

  @override
  State<LoanSummaryPage> createState() => _LoanSummaryPageState();
}

class _LoanSummaryPageState extends State<LoanSummaryPage> {
  String? _lineType;
  String? _line;
  bool _lineAll = true;
  bool _searchByDate = true;
  
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

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.read<LoansBloc>().add(LoadAllLoansRequested());
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
        title: const Text('Loan Summary'),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _searchByDate,
                  activeColor: Colors.lightBlue,
                  onChanged: (val) {
                    setState(() => _searchByDate = val ?? false);
                  },
                ),
                const Text(
                  'Search By Date',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 32),
            BlocBuilder<LoansBloc, LoansState>(
              builder: (context, state) {
                if (state is LoansLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LoansError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                } else if (state is LoansLoaded) {
                  if (state.loans.isEmpty) {
                    return const Center(child: Text('No loans found.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.loans.length,
                    itemBuilder: (context, index) {
                      final loan = state.loans[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Loan ID: ${loan.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Chip(
                                    label: Text(loan.status, style: const TextStyle(fontSize: 12, color: Colors.white)),
                                    backgroundColor: loan.status == 'Active' ? Colors.green : Colors.blueGrey,
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Customer ID: ${loan.customerId}'),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Principal: ₹${loan.principalAmount}'),
                                  Text('Outstanding: ₹${loan.outstandingBalance}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Total Amount: ₹${loan.totalAmount}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
