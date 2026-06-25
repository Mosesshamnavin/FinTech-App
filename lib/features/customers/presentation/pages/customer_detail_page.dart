import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/customer_entity.dart';
import '../../../loans/presentation/bloc/loans_bloc.dart';
import '../../../loans/presentation/bloc/loans_event.dart';
import '../../../loans/presentation/bloc/loans_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

class CustomerDetailPage extends StatelessWidget {
  final CustomerEntity customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoansBloc>()..add(LoadCustomerLoansRequested(customer.id)),
      child: _CustomerDetailView(customer: customer),
    );
  }
}

class _CustomerDetailView extends StatelessWidget {
  final CustomerEntity customer;

  const _CustomerDetailView({required this.customer});

  @override
  Widget build(BuildContext context) {
    String lineName = customer.lineId;
    String areaName = customer.areaId;
    
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      final line = settingsState.lines.where((l) => l.id == customer.lineId).firstOrNull;
      if (line != null) lineName = line.name;
      
      final area = settingsState.areas.where((a) => a.id == customer.areaId).firstOrNull;
      if (area != null) areaName = area.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile'),
      ),
      body: Column(
        children: [
          _buildProfileHeader(context, lineName, areaName),
          const Divider(),
          Expanded(
            child: _buildLoansList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/customers/${customer.id}/add-loan', extra: customer);
          if (result == true && context.mounted) {
            context.read<LoansBloc>().add(LoadCustomerLoansRequested(customer.id));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Assign Loan'),
      ),
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
                  customer.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(customer.phone, style: const TextStyle(color: Colors.grey)),
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
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        } else if (state is LoansLoaded) {
          if (state.loans.isEmpty) {
            return const Center(child: Text('No active loans found.'));
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
                              'Total: ${formatter.format(loan.totalAmount)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: loan.status == 'Active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              loan.status,
                              style: TextStyle(
                                color: loan.status == 'Active' ? Colors.green : Colors.grey,
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
                              const Text('Principal', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(formatter.format(loan.principalAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Interest', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(formatter.format(loan.interestAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Daily Due', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(formatter.format(loan.dailyDueAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Progress (${(progress * 100).toInt()}%)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                          Expanded(child: Text('Paid: ${formatter.format(loan.totalAmount - loan.outstandingBalance)}', style: const TextStyle(fontSize: 12, color: Colors.green))),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Balance: ${formatter.format(loan.outstandingBalance)}', style: const TextStyle(fontSize: 12, color: Colors.orange), textAlign: TextAlign.right)),
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
}
