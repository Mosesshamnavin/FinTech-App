import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../bloc/cashout_bloc.dart';
import '../bloc/cashout_event.dart';
import '../bloc/cashout_state.dart';

import '../widgets/add_cashout_modal.dart';

class CashOutPage extends StatefulWidget {
  const CashOutPage({super.key});

  @override
  State<CashOutPage> createState() => _CashOutPageState();
}

class _CashOutPageState extends State<CashOutPage> {
  String? _selectedLineId;

  @override
  void initState() {
    super.initState();
    // Dispatch initial load
    context.read<CashOutBloc>().add(const LoadCashOutsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CashOut'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, size: 28),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddCashOutModal(),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            tabs: [
              Tab(text: 'ACTIVE'),
              Tab(text: 'HISTORY'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state is SettingsLoaded) {
                    final lines = state.lines;
                    return DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                        labelText: 'Line',
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      isExpanded: true,
                      value: _selectedLineId,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...lines.map((line) {
                          return DropdownMenuItem<String?>(
                            value: line.id,
                            child: Text(line.name),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedLineId = val;
                        });
                        context.read<CashOutBloc>().add(LoadCashOutsRequested(lineId: val));
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<CashOutBloc, CashOutState>(
                builder: (context, state) {
                  if (state is CashOutLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CashOutError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  } else if (state is CashOutLoaded) {
                    return TabBarView(
                      children: [
                        // Active View
                        _buildCashOutList(state.activeCashOuts, isActiveTab: true),
                        // History View
                        _buildCashOutList(state.historyCashOuts, isActiveTab: false),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashOutList(List cashOuts, {required bool isActiveTab}) {
    if (cashOuts.isEmpty) {
      return const Center(child: Text('No CashOuts found.'));
    }
    return ListView.separated(
      itemCount: cashOuts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = cashOuts[index];
        return ListTile(
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount: ₹${item.amount.toStringAsFixed(2)}'),
              Text('Date: ${DateFormat('dd/MM/yyyy').format(item.date)}'),
              if (item.comments.isNotEmpty) Text('Comments: ${item.comments}'),
            ],
          ),
          trailing: isActiveTab
              ? ElevatedButton(
                  onPressed: () {
                    context.read<CashOutBloc>().add(SettleCashOutSubmitted(item.id));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SETTLE'),
                )
              : const Icon(Icons.check_circle, color: Colors.green),
        );
      },
    );
  }
}
