import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/collections_bloc.dart';
import '../bloc/collections_event.dart';
import '../bloc/collections_state.dart';

class AddCollectionModal extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String date;

  const AddCollectionModal({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.date,
  });

  @override
  State<AddCollectionModal> createState() => _AddCollectionModalState();
}

class _AddCollectionModalState extends State<AddCollectionModal> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'paid'; // 'paid', 'pending', 'skipped'

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    context.read<CollectionsBloc>().add(
      AddCollectionRecordSubmitted(
        customerId: widget.customerId,
        amount: amount,
        date: widget.date,
        notes: _notesController.text,
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollectionsBloc, CollectionsState>(
      listener: (context, state) {
        if (state is AddCollectionActionSuccess) {
          Navigator.of(context).pop(true); // Signal success
        } else if (state is AddCollectionActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Collection for ${widget.customerName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Date: ${widget.date}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            
            // Status Toggle
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'paid', label: Text('Paid')),
                ButtonSegment(value: 'pending', label: Text('Pending')),
                ButtonSegment(value: 'skipped', label: Text('Skipped')),
              ],
              selected: {_status},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _status = newSelection.first;
                  if (_status != 'paid') {
                    _amountController.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            
            if (_status == 'paid') ...[
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount Collected',
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
            ],
            
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            
            BlocBuilder<CollectionsBloc, CollectionsState>(
              builder: (context, state) {
                final isLoading = state is AddCollectionActionLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('SAVE RECORD'),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
