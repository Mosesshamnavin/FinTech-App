import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:vasooldrive/core/services/app_localization.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';
import '../bloc/customers_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

import '../../domain/entities/customer_entity.dart';

class AddCustomerPage extends StatelessWidget {
  final CustomerEntity? customer;

  const AddCustomerPage({super.key, this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomersBloc>(),
      child: _AddCustomerView(customer: customer),
    );
  }
}

class _AddCustomerView extends StatefulWidget {
  final CustomerEntity? customer;
  const _AddCustomerView({this.customer});

  @override
  State<_AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<_AddCustomerView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedLine;
  String? _selectedArea;
  bool get _isEditMode => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone;
      _addressController.text = widget.customer!.address;
      _selectedLine = widget.customer!.lineId;
      _selectedArea = widget.customer!.areaId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_isEditMode) {
      context.read<CustomersBloc>().add(
            UpdateCustomerSubmitted(
              id: widget.customer!.id,
              name: _nameController.text,
              phone: _phoneController.text,
              address: _addressController.text,
              lineId: _selectedLine ?? '',
              areaId: _selectedArea ?? '',
            ),
          );
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalization.languageNotifier,
      builder: (context, language, child) {
        return BlocListener<CustomersBloc, CustomersState>(
          listener: (context, state) {
            if (state is AddCustomerSuccess || state is UpdateCustomerSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isEditMode ? 'Customer updated successfully!'.tr() : 'Customer added successfully!'.tr()),
                  backgroundColor: context.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pop(true); // Return true to signal a refresh is needed
            } else if (state is AddCustomerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: context.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is UpdateCustomerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: context.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(_isEditMode ? 'Edit Customer'.tr() : 'Add Customer'.tr()),
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
                    decoration: InputDecoration(labelText: 'Customer Name'.tr()),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Mobile Number'.tr()),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: 'Address'.tr()),
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      if (state is SettingsLoaded) {
                        final lines = state.lines;
                        final areas = state.areas;
                        return Column(
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(labelText: 'Line'.tr()),
                              value: _selectedLine,
                              items: lines.map((line) {
                                return DropdownMenuItem(value: line.id, child: Text(line.name));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedLine = val),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(labelText: 'Area'.tr()),
                              value: _selectedArea,
                              items: areas.map((area) {
                                return DropdownMenuItem(value: area.id, child: Text(area.name));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedArea = val),
                            ),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<CustomersBloc, CustomersState>(
                    builder: (context, customersState) {
                      final isLoading = customersState is AddCustomerLoading || customersState is UpdateCustomerLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _isEditMode ? 'Update Record'.tr() : 'Save Record'.tr(),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
