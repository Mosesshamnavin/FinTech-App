import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/sms_service.dart';
import 'package:vasooldrive/core/services/app_localization.dart';
import '../bloc/collections_bloc.dart';
import '../bloc/collections_event.dart';
import '../bloc/collections_state.dart';
import '../../../loans/presentation/bloc/loans_bloc.dart';
import '../../../loans/presentation/bloc/loans_state.dart';
import '../../../loans/domain/entities/loan_entity.dart';
import '../../domain/entities/collection_entity.dart';

class AddCollectionModal extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String date;
  final CollectionEntity? collection;

  const AddCollectionModal({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    this.collection,
  });

  @override
  State<AddCollectionModal> createState() => _AddCollectionModalState();
}

class _AddCollectionModalState extends State<AddCollectionModal> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _status = 'paid'; // 'paid', 'pending', 'skipped'
  LoanEntity? _selectedLoan;

  @override
  void initState() {
    super.initState();
    if (widget.collection != null) {
      _amountController.text = widget.collection!.amount.toStringAsFixed(0);
      _notesController.text = widget.collection!.notes ?? '';
      _status = widget.collection!.status;
      // We don't pre-fill _selectedLoan directly because we need to fetch active loans first
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    String? selectedLoanId = _selectedLoan?.id;
    if (selectedLoanId == null && _status == 'paid') {
      final loansState = context.read<LoansBloc>().state;
      if (loansState is LoansLoaded) {
        final activeLoans = loansState.loans.where((l) => l.status == 'Active').toList();
        if (activeLoans.isNotEmpty) {
          selectedLoanId = activeLoans.first.id;
        }
      }
    }
    
    if (widget.collection != null) {
      context.read<CollectionsBloc>().add(
        UpdateCollectionRecordSubmitted(
          id: widget.collection!.id,
          amount: amount,
          notes: _notesController.text,
          status: _status,
        ),
      );
    } else {
      context.read<CollectionsBloc>().add(
        AddCollectionRecordSubmitted(
          customerId: widget.customerId,
          loanId: selectedLoanId,
          amount: amount,
          date: widget.date,
          notes: _notesController.text,
          status: _status,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalization.languageNotifier,
      builder: (context, language, child) {
        return BlocListener<CollectionsBloc, CollectionsState>(
          listener: (context, state) {
            if (state is AddCollectionActionSuccess) {
              final storage = sl<StorageService>();
              final sendSmsEnabled = storage.getBool('my_settings_send_sms');
              if (sendSmsEnabled && _status == 'paid') {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogCtx) {
                    final phoneController = TextEditingController(text: widget.customerPhone);
                    return StatefulBuilder(
                      builder: (context, setState) {
                        final hasPhone = phoneController.text.trim().isNotEmpty;
                        return AlertDialog(
                          title: Text('Send Receipt'.tr()),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('${'Send collection receipt to'.tr()} ${widget.customerName}?'),
                              const SizedBox(height: 16),
                              TextField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Customer Mobile Number'.tr(),
                                  hintText: 'Enter 10-digit number'.tr(),
                                  prefixText: '+91 ',
                                ),
                                keyboardType: TextInputType.phone,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogCtx);
                                Navigator.pop(context, true);
                              },
                              child: Text('CANCEL'.tr()),
                            ),
                            TextButton(
                              onPressed: !hasPhone ? null : () async {
                                Navigator.pop(dialogCtx);
                                final text = await sl<SmsService>().composeMessage(
                                  flow: 'Collection',
                                  language: 'en',
                                  customerName: widget.customerName,
                                  amountPaidToday: double.tryParse(_amountController.text) ?? 0.0,
                                  date: widget.date,
                                  customerId: widget.customerId,
                                );
                                await sl<SmsService>().sendWhatsApp(phone: phoneController.text, text: text);
                                if (context.mounted) Navigator.pop(context, true);
                              },
                              child: Text('WHATSAPP'.tr()),
                            ),
                            TextButton(
                              onPressed: !hasPhone ? null : () async {
                                Navigator.pop(dialogCtx);
                                final text = await sl<SmsService>().composeMessage(
                                  flow: 'Collection',
                                  language: 'en',
                                  customerName: widget.customerName,
                                  amountPaidToday: double.tryParse(_amountController.text) ?? 0.0,
                                  date: widget.date,
                                  customerId: widget.customerId,
                                );
                                await sl<SmsService>().sendSMS(phone: phoneController.text, text: text);
                                if (context.mounted) Navigator.pop(context, true);
                              },
                              child: Text('SMS'.tr()),
                            ),
                          ],
                        );
                      }
                    );
                  }
                );
              } else {
                Navigator.of(context).pop(true);
              }
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.collection != null 
                          ? '${'Edit Collection for'.tr()} ${widget.customerName}'
                          : '${'Add Collection for'.tr()} ${widget.customerName}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.collection != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // We are not adding the delete event to AddCollectionModal directly right now,
                          // as per discussion, delete happens on Customer page.
                          // Wait, the plan says: "Delete Button: Add a red Trash icon in the header...".
                          // Let's implement VoidCollectionRecordSubmitted here.
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Delete Collection'.tr()),
                              content: Text('Are you sure you want to delete this payment?'.tr()),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: Text('CANCEL'.tr())),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context.read<CollectionsBloc>().add(VoidCollectionRecordSubmitted(
                                      collectionId: widget.collection!.id,
                                      loanId: widget.collection!.loanId,
                                      amount: widget.collection!.amount,
                                    ));
                                    Navigator.pop(context, true);
                                  },
                                  child: Text('DELETE'.tr(), style: const TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${'Date'.tr()}: ${widget.date}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                
                // Status Toggle
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'paid', label: Text('Paid'.tr())),
                    ButtonSegment(value: 'pending', label: Text('Pending'.tr())),
                    ButtonSegment(value: 'skipped', label: Text('Skipped'.tr())),
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
                  BlocBuilder<LoansBloc, LoansState>(
                    builder: (context, loansState) {
                      if (loansState is LoansLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (loansState is LoansLoaded) {
                        final activeLoans = loansState.loans.where((l) => l.status == 'Active').toList();
                        if (activeLoans.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No active loans found for this customer.'.tr(),
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
    
                        // Pre-fill selected loan if editing
                        LoanEntity? initialLoan;
                        if (_selectedLoan != null && activeLoans.any((l) => l.id == _selectedLoan!.id)) {
                          initialLoan = activeLoans.firstWhere((l) => l.id == _selectedLoan!.id);
                        } else if (widget.collection != null && activeLoans.any((l) => l.id == widget.collection!.loanId)) {
                          initialLoan = activeLoans.firstWhere((l) => l.id == widget.collection!.loanId);
                        } else {
                          initialLoan = activeLoans.first;
                        }
                        
                        // Wait to update state to avoid build errors
                        if (_selectedLoan == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _selectedLoan = initialLoan);
                          });
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: DropdownButtonFormField<LoanEntity>(
                            value: initialLoan,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Select Loan for Payment'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                            items: activeLoans.map((loan) {
                              return DropdownMenuItem<LoanEntity>(
                                value: loan,
                                child: Text(
                                  '${'Pending'.tr()}: ₹${loan.outstandingBalance.toStringAsFixed(0)} | ${'Due'.tr()}: ₹${loan.dailyDueAmount.toStringAsFixed(0)}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (loan) {
                              setState(() {
                                _selectedLoan = loan;
                              });
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount Collected'.tr(),
                      prefixText: '₹ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                ],
                
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: 'Notes (Optional)'.tr()),
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
                          : Text(widget.collection != null ? 'UPDATE RECORD'.tr() : 'SAVE RECORD'.tr()),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
