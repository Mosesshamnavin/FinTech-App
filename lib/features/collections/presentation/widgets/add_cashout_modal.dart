import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/cashout_entity.dart';
import '../bloc/cashout_bloc.dart';
import '../bloc/cashout_event.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

class AddCashOutModal extends StatefulWidget {
  const AddCashOutModal({super.key});

  @override
  State<AddCashOutModal> createState() => _AddCashOutModalState();
}

class _AddCashOutModalState extends State<AddCashOutModal> {
  String? _selectedLineId;
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
      if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add CashOut'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.xmark),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      if (state is SettingsLoaded) {
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                          isExpanded: true,
                          value: _selectedLineId,
                          hint: const Text('Line', style: TextStyle(fontSize: 16)),
                          items: state.lines.map((line) {
                            return DropdownMenuItem<String>(
                              value: line.id,
                              child: Text(line.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedLineId = val;
                            });
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(top: 14.0, bottom: 14.0),
                          child: FaIcon(FontAwesomeIcons.calendarDay, color: Colors.lightBlue, size: 20),
                        ),
                        suffixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 0),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentsController,
                    decoration: const InputDecoration(
                      labelText: 'Comments',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedLineId == null || _amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Line and enter amount')));
                    return;
                  }
                  final newCashOut = CashOutEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    lineId: _selectedLineId!,
                    amount: double.tryParse(_amountController.text) ?? 0.0,
                    date: _selectedDate,
                    name: _nameController.text,
                    comments: _commentsController.text,
                  );
                  context.read<CashOutBloc>().add(AddCashOutSubmitted(newCashOut));
                  Navigator.of(context).pop();
                },
                child: const Text('SUBMIT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
