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
      ],
      child: _CustomerDetailView(customer: customer),
    );
  }
}

class _CustomerDetailView extends StatefulWidget {
  final CustomerEntity customer;

  const _CustomerDetailView({required this.customer});

  @override
  State<_CustomerDetailView> createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<_CustomerDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              // Reload both Blocs to update UI and balances
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
          child: Scaffold(
            appBar: AppBar(
              title: Text('Customer Profile'.tr()),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Loans'.tr()),
                  Tab(text: 'Payments'.tr()),
                ],
              ),
            ),
            body: Column(
              children: [
                _buildProfileHeader(context, lineName, areaName),
                const Divider(height: 1),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoansList(),
                      _buildPaymentsList(context),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                final result = await context.push('/customers/${widget.customer.id}/add-loan', extra: widget.customer);
                if (result == true && context.mounted) {
                  context.read<LoansBloc>().add(LoadCustomerLoansRequested(widget.customer.id));
                }
              },
              icon: const Icon(Icons.add),
              label: Text('Assign Loan'.tr()),
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

  Widget _buildPaymentsList(BuildContext context) {
    return BlocBuilder<CollectionsBloc, CollectionsState>(
      builder: (context, state) {
        if (state is CustomerCollectionsLoading || state is VoidCollectionActionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CustomerCollectionsError) {
          return Center(child: Text(state.message.tr(), style: TextStyle(color: context.danger)));
        } else if (state is CustomerCollectionsLoaded) {
          if (state.collections.isEmpty) {
            return Center(child: Text('No payments found.'.tr(), style: const TextStyle(color: Colors.grey)));
          }

          final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.collections.length,
            itemBuilder: (context, index) {
              final collection = state.collections[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundColor: collection.status == 'paid' ? context.successLight : context.surfaceVariant,
                    child: FaIcon(
                      collection.status == 'paid' ? FontAwesomeIcons.check : FontAwesomeIcons.clock,
                      color: collection.status == 'paid' ? context.success : context.textMuted,
                      size: 16,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        formatter.format(collection.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: collection.status == 'paid' ? context.successLight : context.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          collection.status.toUpperCase().tr(),
                          style: TextStyle(
                            color: collection.status == 'paid' ? context.success : context.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(collection.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      if (collection.notes != null && collection.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(collection.notes!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      ]
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // IconButton(
                      //   icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
                      //   onPressed: () => _shareReceipt(context, collection),
                      //   tooltip: 'Share Receipt',
                      // ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.trash, color: Colors.red, size: 16),
                        onPressed: () => _voidCollection(context, collection.id),
                        tooltip: 'Delete Payment',
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
