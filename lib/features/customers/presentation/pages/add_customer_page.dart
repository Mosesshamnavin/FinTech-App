import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';
import '../bloc/customers_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

class AddCustomerPage extends StatelessWidget {
  const AddCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomersBloc>(),
      child: const _AddCustomerView(),
    );
  }
}

class _AddCustomerView extends StatefulWidget {
  const _AddCustomerView();

  @override
  State<_AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<_AddCustomerView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedLine;
  String? _selectedArea;

  // Removed mock lists

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    context.read<CustomersBloc>().add(
          AddCustomerSubmitted(
            name: _nameController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            lineId: _selectedLine ?? '',
            areaId: _selectedArea ?? '',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomersBloc, CustomersState>(
      listener: (context, state) {
        if (state is AddCustomerSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer added successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop(true); // Return true to signal a refresh is needed
        } else if (state is AddCustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Customer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  List<String> lines = [];
                  List<String> areas = [];
                  if (state is SettingsLoaded) {
                    lines = state.lines.map((e) => e.name).toList();
                    areas = state.areas.map((e) => e.name).toList();
                  }
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Line'),
                        value: _selectedLine,
                        items: lines.map((line) {
                          return DropdownMenuItem(value: line, child: Text(line));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedLine = val),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Area'),
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
              const SizedBox(height: 32),
              BlocBuilder<CustomersBloc, CustomersState>(
                builder: (context, state) {
                  final isLoading = state is AddCustomerLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _onSubmit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('SUBMIT'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
