import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense_entity.dart';
import 'package:vasooldrive/core/services/app_localization.dart';
import '../bloc/expenses_bloc.dart';
import '../bloc/expenses_event.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

class AddExpenseModal extends StatefulWidget {
  final bool isInvestment;
  final ExpenseEntity? expense;

  const AddExpenseModal({
    super.key,
    required this.isInvestment,
    this.expense,
  });

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  late DateTime _selectedDate;
  late String _selectedCategory;
  late bool _isOnline;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toStringAsFixed(0);
      _descController.text = widget.expense!.description;
      _selectedDate = widget.expense!.date;
      _isOnline = widget.expense!.isOnline;
      // We need to resolve UUID to Name for the dropdown
      // This will be done in the build method below
      _selectedCategory = widget.expense!.category; 
    } else {
      _selectedDate = DateTime.now();
      _selectedCategory = 'Food'; // Default, will be overridden
      _isOnline = false;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Look up the actual UUID of the category from SettingsBloc
    String typeId = _selectedCategory; // Fallback to name just in case
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      if (widget.isInvestment) {
        final match = settingsState.investmentTypes.where((e) => e.name == _selectedCategory).toList();
        if (match.isNotEmpty) typeId = match.first.id;
      } else {
        final match = settingsState.expenseTypes.where((e) => e.name == _selectedCategory).toList();
        if (match.isNotEmpty) typeId = match.first.id;
      }
    }

    if (widget.expense != null) {
      final updatedExpense = ExpenseEntity(
        id: widget.expense!.id,
        amount: amount,
        category: typeId,
        description: _descController.text,
        date: _selectedDate,
        isInvestment: widget.isInvestment,
        isOnline: _isOnline,
        lineId: widget.expense!.lineId,
      );
      context.read<ExpensesBloc>().add(UpdateExpenseSubmitted(updatedExpense));
    } else {
      final newExpense = ExpenseEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        category: typeId,
        description: _descController.text,
        date: _selectedDate,
        isInvestment: widget.isInvestment,
        isOnline: _isOnline,
      );
      context.read<ExpensesBloc>().add(AddExpenseSubmitted(newExpense));
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.expense == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${widget.isInvestment ? 'Investment' : 'Expense'}'.tr()),
        content: Text('Are you sure you want to delete this record?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              context.read<ExpensesBloc>().add(DeleteExpenseSubmitted(widget.expense!.id, widget.isInvestment));
              Navigator.of(context).pop(); // Close modal
            },
            child: Text('Delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalization.languageNotifier,
      builder: (context, language, child) {
        return Padding(
          // Padding to account for keyboard
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.expense != null 
                        ? 'Edit ${widget.isInvestment ? 'Investment' : 'Expense'}'.tr()
                        : 'Add ${widget.isInvestment ? 'Investment' : 'Expense'}'.tr(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (widget.expense != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _delete,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount'.tr(),
                  prefixText: '₹ ',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  List<String> categories = ['Other'];
                  if (state is SettingsLoaded) {
                    if (widget.isInvestment) {
                      if (state.investmentTypes.isNotEmpty) {
                        categories = state.investmentTypes.map((e) => e.name).toList();
                      }
                    } else {
                      if (state.expenseTypes.isNotEmpty) {
                        categories = state.expenseTypes.map((e) => e.name).toList();
                      }
                    }
                  }
                  // Make sure _selectedCategory is valid
                  if (!categories.contains(_selectedCategory)) {
                    _selectedCategory = categories.first;
                  }
        
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)'.tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date'.tr(),
                          border: const OutlineInputBorder(),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text('Payment Mode'.tr()),
                      Switch(
                        value: _isOnline,
                        onChanged: (val) => setState(() => _isOnline = val),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      Text(_isOnline ? 'Online'.tr() : 'Cash'.tr(), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(widget.expense != null ? 'Update'.tr() : 'Save'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
