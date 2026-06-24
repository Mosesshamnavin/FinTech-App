import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';
import '../bloc/customers_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomersBloc>()..add(const LoadCustomersRequested()),
      child: const _CustomersView(),
    );
  }
}

class _CustomersView extends StatefulWidget {
  const _CustomersView();

  @override
  State<_CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<_CustomersView> {
  String? _selectedLine;
  String? _selectedArea;

  void _onFilterSubmitted() {
    context.read<CustomersBloc>().add(
          LoadCustomersRequested(lineId: _selectedLine, areaId: _selectedArea),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.userPlus, size: 20),
            onPressed: () async {
              // Wait for the AddCustomerPage to pop, and if true, reload customers
              final shouldReload = await context.push('/customers/add');
              if (shouldReload == true && context.mounted) {
                context.read<CustomersBloc>().add(const LoadCustomersRequested());
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    List<String> lines = [];
                    List<String> areas = [];
                    if (state is SettingsLoaded) {
                      lines = state.lines.map((e) => e.name).toList();
                      areas = state.areas.map((e) => e.name).toList();
                    }
                    if (_selectedLine != null && !lines.contains(_selectedLine)) {
                      _selectedLine = null;
                    }
                    if (_selectedArea != null && !areas.contains(_selectedArea)) {
                      _selectedArea = null;
                    }

                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(hintText: 'Select Line'),
                          value: _selectedLine,
                          items: lines.map((line) {
                            return DropdownMenuItem(value: line, child: Text(line));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedLine = val),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(hintText: 'Select Area'),
                          value: _selectedArea,
                          items: areas.map((area) {
                            return DropdownMenuItem(value: area, child: Text(area));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedArea = val),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onFilterSubmitted,
                    child: const Text('SUBMIT'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // List Section
          Expanded(
            child: BlocBuilder<CustomersBloc, CustomersState>(
              builder: (context, state) {
                if (state is CustomersLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CustomersError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is CustomersLoaded) {
                  if (state.customers.isEmpty) {
                    return const Center(
                      child: Text('No customers found.'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.customers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final customer = state.customers[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                          title: Text(
                            customer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer.phone),
                              Text(
                                '${customer.lineId} - ${customer.areaId}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
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
