import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../widgets/add_line_modal.dart';
import '../widgets/area_search_modal.dart';
import '../widgets/add_collection_modal.dart';
import '../bloc/collections_bloc.dart';
import '../bloc/collections_event.dart';
import '../bloc/collections_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CollectionsBloc>(),
      child: const _CollectionsView(),
    );
  }
}

class _CollectionsView extends StatefulWidget {
  const _CollectionsView();

  @override
  State<_CollectionsView> createState() => _CollectionsViewState();
}

class _CollectionsViewState extends State<_CollectionsView> {
  String? _selectedLine;
  String? _selectedArea;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to today
    final now = DateTime.now();
    _dateController.text = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  @override
  void dispose() {
    _dateController.dispose();
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
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _onSubmit() {
    context.read<CollectionsBloc>().add(
      LoadDailyCollectionsRequested(
        date: _dateController.text,
        lineId: _selectedLine,
        areaId: _selectedArea,
      ),
    );
  }

  void _showAddCollectionModal(BuildContext context, String customerId, String customerName) async {
    // Provide the existing bloc to the modal so it can fire events
    final bloc = context.read<CollectionsBloc>();
    
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: AddCollectionModal(
          customerId: customerId,
          customerName: customerName,
          date: _dateController.text,
        ),
      ),
    );

    // If modal returned true (success), reload the list to show new data
    if (result == true && context.mounted) {
      _onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.wallet, size: 20),
            onPressed: () => context.push('/collections/cashout'),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.calculator, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell, size: 20),
            onPressed: () => context.push('/collections/reminders'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(top: 14.0, bottom: 14.0),
                      child: FaIcon(FontAwesomeIcons.calendarDay, color: Colors.lightBlue, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    List<DropdownMenuItem<String>> lineItems = [];
                    List<DropdownMenuItem<String>> areaItems = [];
                    if (state is SettingsLoaded) {
                      lineItems = state.lines.map((e) {
                        return DropdownMenuItem<String>(value: e.id, child: Text(e.name));
                      }).toList();
                      areaItems = state.areas.map((e) {
                        return DropdownMenuItem<String>(value: e.id, child: Text(e.name));
                      }).toList();
                    }
                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedLine,
                          decoration: const InputDecoration(hintText: 'Line'),
                          items: lineItems,
                          onChanged: (val) => setState(() => _selectedLine = val),
                          icon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.plus, size: 20),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => const AddLineModal(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedArea,
                          decoration: const InputDecoration(hintText: 'Area'),
                          items: areaItems,
                          onChanged: (val) => setState(() => _selectedArea = val),
                          icon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, color: Colors.lightBlue, size: 20),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => const AreaSearchModal(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedLine = null;
                            _selectedArea = null;
                          });
                          // Optionally also trigger a reload immediately, 
                          // but usually clear just clears the form
                          _onSubmit();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('CLEAR'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        child: const Text('SUBMIT'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Daily Collection List
          Expanded(
            child: BlocBuilder<CollectionsBloc, CollectionsState>(
              buildWhen: (previous, current) {
                // Only rebuild list on these states, ignore AddCollection action states
                return current is DailyCollectionsLoading || 
                       current is DailyCollectionsLoaded || 
                       current is DailyCollectionsError || 
                       current is CollectionsInitial;
              },
              builder: (context, state) {
                if (state is CollectionsInitial) {
                  return const Center(
                    child: Text('Select filters and tap SUBMIT to load sheet.'),
                  );
                } else if (state is DailyCollectionsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DailyCollectionsError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                } else if (state is DailyCollectionsLoaded) {
                  if (state.dailyList.isEmpty) {
                    return const Center(child: Text('No customers found for this line/area.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.dailyList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = state.dailyList[index];
                      final customer = item.customer;
                      final collection = item.collection;

                      // Find names from settings state if available
                      String lineName = customer.lineId;
                      String areaName = customer.areaId;
                      
                      final settingsState = context.read<SettingsBloc>().state;
                      if (settingsState is SettingsLoaded) {
                        final line = settingsState.lines.where((l) => l.id == customer.lineId).firstOrNull;
                        if (line != null) lineName = line.name;
                        
                        final area = settingsState.areas.where((a) => a.id == customer.areaId).firstOrNull;
                        if (area != null) areaName = area.name;
                      }

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: item.hasPaid ? Colors.green.shade300 : Colors.grey.shade300,
                            width: item.hasPaid ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => _showAddCollectionModal(context, customer.id, customer.name),
                          leading: CircleAvatar(
                            backgroundColor: item.hasPaid ? Colors.green.shade100 : Colors.blue.shade100,
                            child: Icon(
                              item.hasPaid ? Icons.check : Icons.person,
                              color: item.hasPaid ? Colors.green : Colors.blue,
                            ),
                          ),
                          title: Text(
                            customer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('$lineName - $areaName'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (collection != null) ...[
                                if (collection.status == 'paid')
                                  Text(
                                    '₹ ${collection.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )
                                else
                                  Text(
                                    collection.status.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                              ] else ...[
                                const Text(
                                  'Pending',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
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
          ),
        ],
      ),
    );
  }
}
