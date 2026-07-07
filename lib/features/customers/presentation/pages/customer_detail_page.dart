import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/customer_entity.dart';
import '../../../loans/presentation/bloc/loans_bloc.dart';
import '../../../loans/presentation/bloc/loans_event.dart';
import '../../../loans/presentation/bloc/loans_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../collections/presentation/bloc/collections_bloc.dart';
import '../../../collections/presentation/bloc/collections_event.dart';
import '../../../collections/presentation/bloc/collections_state.dart';
import '../../../collections/domain/entities/collection_entity.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';
import '../bloc/customers_state.dart';
import 'add_customer_page.dart';
import '../../../../core/services/sms_service.dart';
import '../../../../core/services/app_localization.dart';

class CustomerDetailPage extends StatelessWidget {
  final CustomerEntity customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<LoansBloc>()..add(LoadCustomerLoansRequested(customer.id)),
        ),
        BlocProvider(
          create: (_) => sl<CollectionsBloc>()..add(LoadCustomerCollectionsRequested(customerId: customer.id)),
        ),
        BlocProvider(
          create: (_) => sl<CustomersBloc>(),
        ),
      ],
      child: _CustomerDetailView(customer: customer),
    );
  }
}

class _CustomerDetailView extends StatefulWidget {
  final CustomerEntity customer;

  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<LoansBloc>().add(LoadCustomerLoansRequested(widget.customer.id));
    context.read<CollectionsBloc>().add(LoadCustomerCollectionsRequested(customerId: widget.customer.id));
  }

  void _voidCollection(BuildContext context, String collectionId) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('Delete Payment'.tr()),
          content: Text('Are you sure you want to delete this payment?'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('CANCEL'.tr()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.read<CollectionsBloc>().add(VoidCollectionRecordSubmitted(collectionId: collectionId));
              },
              child: Text('DELETE'.tr(), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteCustomer(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('Delete Customer'.tr()),
          content: Text('Are you sure you want to delete this customer? This will hide them from the app.'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('CANCEL'.tr()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.read<CustomersBloc>().add(DeleteCustomerSubmitted(id: widget.customer.id));
              },
              child: Text('DELETE'.tr(), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _shareReceipt(BuildContext context, CollectionEntity collection) async {
    final smsService = sl<SmsService>();
    final lang = AppLocalization.languageNotifier.value == 'தமிழ்' ? 'ta' : 'en';
    final msg = await smsService.composeMessage(
      flow: 'Collection',
      language: lang,
      customerName: widget.customer.name,
      amountPaidToday: collection.amount,
      date: collection.date,
      customerId: widget.customer.id,
    );
    await smsService.sendWhatsApp(phone: widget.customer.phone, text: msg);
  }

  @override
  Widget build(BuildContext context) {
    String lineName = widget.customer.lineId;
    String areaName = widget.customer.areaId;
    
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      final line = settingsState.lines.where((l) => l.id == widget.customer.lineId).firstOrNull;
      if (line != null) lineName = line.name;
      
      final area = settingsState.areas.where((a) => a.id == widget.customer.areaId).firstOrNull;
      if (area != null) areaName = area.name;
    }

    return ValueListenableBuilder<String>(
      valueListenable: AppLocalization.languageNotifier,
      builder: (context, language, child) {
        return BlocListener<CollectionsBloc, CollectionsState>(
          listener: (context, state) {
            if (state is VoidCollectionActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment deleted successfully!'.tr()),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<LoansBloc>().add(LoadCustomerLoansRequested(widget.customer.id));
              context.read<CollectionsBloc>().add(LoadCustomerCollectionsRequested(customerId: widget.customer.id));
            } else if (state is VoidCollectionActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocListener<CustomersBloc, CustomersState>(
            listener: (context, state) {
              if (state is DeleteCustomerSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Customer deleted successfully!'.tr()),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pop(true);
              } else if (state is DeleteCustomerError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text('Customer Profile'.tr()),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final shouldRefresh = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => AddCustomerPage(customer: widget.customer)),
                        );
                        if (shouldRefresh == true) {
                          context.pop(true);
                        }
                      } else if (value == 'delete') {
                        _deleteCustomer(context);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20),
                              const SizedBox(width: 8),
                              Text('Edit Customer'.tr()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text('Delete Customer'.tr(), style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
                }
              },
              icon: const Icon(Icons.add),
              label: Text('Assign Loan'.tr()),
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, String lineName, String areaName) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, size: 32, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customer.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(widget.customer.phone, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.locationDot, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('$lineName - $areaName', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoansList() {
    return BlocBuilder<LoansBloc, LoansState>(
      builder: (context, state) {
        if (state is LoansLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LoansError) {
          return Center(child: Text(state.message.tr(), style: TextStyle(color: context.danger)));
        } else if (state is LoansLoaded) {
          if (state.loans.isEmpty) {
            return Center(child: Text('No active loans found.'.tr(), style: const TextStyle(color: Colors.grey)));
          }

          final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.loans.length,
            itemBuilder: (context, index) {
              final loan = state.loans[index];
              final progress = (loan.totalAmount - loan.outstandingBalance) / loan.totalAmount;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${'Total'.tr()}: ${formatter.format(loan.totalAmount)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: loan.status == 'Active' ? context.successLight : context.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            loan.status.tr(),
                            style: TextStyle(
                              color: loan.status == 'Active' ? context.success : context.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Principal'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(formatter.format(loan.principalAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Interest'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(formatter.format(loan.interestAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Daily Due'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(formatter.format(loan.dailyDueAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('${'Progress'.tr()} (${(progress * 100).toInt()}%)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text('${'Paid'.tr()}: ${formatter.format(loan.totalAmount - loan.outstandingBalance)}', style: TextStyle(fontSize: 12, color: context.success))),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${'Balance'.tr()}: ${formatter.format(loan.outstandingBalance)}', style: TextStyle(fontSize: 12, color: context.warning), textAlign: TextAlign.right)),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment History'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        TextButton.icon(
                          onPressed: () async {
                            final result = await context.push('/customers/${widget.customer.id}/add-loan', extra: {
                              'customer': widget.customer,
                              'loan': loan,
                            });
                            if (result == true && context.mounted) {
                              context.read<LoansBloc>().add(LoadCustomerLoansRequested(widget.customer.id));
                            }
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: Text('Edit Loan'.tr(), style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CollectionsBloc, CollectionsState>(
                      builder: (context, collectionsState) {
                        if (collectionsState is CustomerCollectionsLoading || collectionsState is VoidCollectionActionLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (collectionsState is CustomerCollectionsLoaded) {
                          final loanPayments = collectionsState.collections.where((c) => c.loanId == loan.id).toList();
                          
                          if (loanPayments.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('No payments found for this loan.'.tr(), style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                            );
                          }
                          
                          return Column(
                            children: loanPayments.map((collection) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: collection.status == 'paid' ? context.successLight : context.surfaceVariant,
                                      child: FaIcon(
                                        collection.status == 'paid' ? FontAwesomeIcons.check : FontAwesomeIcons.clock,
                                        color: collection.status == 'paid' ? context.success : context.textMuted,
                                        size: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                formatter.format(collection.amount),
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: collection.status == 'paid' ? context.successLight : context.surfaceVariant,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  collection.status.toUpperCase().tr(),
                                                  style: TextStyle(
                                                    color: collection.status == 'paid' ? context.success : context.textMuted,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(collection.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          if (collection.notes != null && collection.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(collection.notes!, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                                          ]
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const FaIcon(FontAwesomeIcons.trash, color: Colors.red, size: 14),
                                      onPressed: () => _voidCollection(context, collection.id),
                                      tooltip: 'Delete Payment',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  }
}
