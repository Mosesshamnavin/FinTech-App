import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vasooldrive/core/services/app_localization.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/add_line_modal.dart';
import '../widgets/area_search_modal.dart';
import '../widgets/calculator_modal.dart';
import '../widgets/add_collection_modal.dart';
import '../bloc/collections_bloc.dart';
import '../bloc/collections_event.dart';
import '../bloc/collections_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../settings/domain/entities/settings_entities.dart';
import '../../../loans/presentation/bloc/loans_bloc.dart';
import '../../../loans/presentation/bloc/loans_event.dart';

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

  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    // Default to today
    final now = DateTime.now();
    _dateController.text = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    
    // Auto-load collections on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onSubmit();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isVisible = TickerMode.of(context);
    if (isVisible && !_wasVisible) {
      // Trigger a silent reload when tab becomes visible
      _onSubmit();
    }
    _wasVisible = isVisible;
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

  void _showAddCollectionModal(BuildContext context, String customerId, String customerName, String customerPhone) async {
    // Provide the existing bloc to the modal so it can fire events
    final bloc = context.read<CollectionsBloc>();
    
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: bloc),
          BlocProvider(
            create: (_) => sl<LoansBloc>()..add(LoadCustomerLoansRequested(customerId)),
          ),
        ],
        child: AddCollectionModal(
          customerId: customerId,
          customerName: customerName,
          customerPhone: customerPhone,
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
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalization.languageNotifier,
      builder: (context, language, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Collection'.tr()),
            actions: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.wallet, size: 20),
                onPressed: () => context.push('/collections/cashout'),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.calculator, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CalculatorModal(),
                  );
                },
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
                      decoration: InputDecoration(
                        labelText: 'Date'.tr(),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                          child: FaIcon(FontAwesomeIcons.calendarDay, color: context.accent, size: 20),
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
                              decoration: InputDecoration(hintText: 'Line'.tr()),
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
                              decoration: InputDecoration(hintText: 'Area'.tr()),
                              items: areaItems,
                              onChanged: (val) => setState(() => _selectedArea = val),
                              icon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  IconButton(
                                    icon: FaIcon(FontAwesomeIcons.magnifyingGlass, color: context.accent, size: 20),
                                    onPressed: () async {
                                      List<AreaEntity> currentAreas = [];
                                      if (state is SettingsLoaded) {
                                        currentAreas = state.areas;
                                      }
                                      final selectedId = await showDialog<String>(
                                        context: context,
                                        builder: (context) => AreaSearchModal(areas: currentAreas),
                                      );
                                      if (selectedId != null && mounted) {
                                        setState(() {
                                          _selectedArea = selectedId;
                                        });
                                        _onSubmit();
                                      }
                                    },
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
                              side: BorderSide(color: context.danger),
                              foregroundColor: context.danger,
                            ),
                            child: Text('CLEAR'.tr()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _onSubmit,
                            child: Text('SUBMIT'.tr()),
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
                child: BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, settingsState) {
                    return BlocBuilder<CollectionsBloc, CollectionsState>(
                      buildWhen: (previous, current) {
                        return current is DailyCollectionsLoading || 
                               current is DailyCollectionsLoaded || 
                               current is DailyCollectionsError || 
                               current is CollectionsInitial;
                      },
                      builder: (context, state) {
                        if (state is CollectionsInitial) {
                          return Center(
                            child: Text('Select filters and tap SUBMIT to load sheet.'.tr()),
                          );
                        } else if (state is DailyCollectionsLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is DailyCollectionsError) {
                          return Center(child: Text(state.message, style: TextStyle(color: context.danger)));
                        } else if (state is DailyCollectionsLoaded) {
                          if (state.dailyList.isEmpty) {
                            return Center(child: Text('No customers found for this line/area.'.tr()));
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
                              String lineName = 'Unknown Line';
                              String areaName = 'Unknown Area';
                              
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
                                    color: item.hasPaid ? context.success : context.surfaceVariant,
                                    width: item.hasPaid ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () => _showAddCollectionModal(context, customer.id, customer.name, customer.phone),
                                  leading: CircleAvatar(
                                    backgroundColor: item.hasPaid ? context.successLight : context.primaryContainer,
                                    child: Icon(
                                      item.hasPaid ? Icons.check : Icons.person,
                                      color: item.hasPaid ? context.success : context.primary,
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
                                            style: TextStyle(
                                              color: context.success,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          )
                                        else
                                          Text(
                                            collection.status.toUpperCase(),
                                            style: TextStyle(
                                              color: context.warning,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                      ] else ...[
                                        Text(
                                          'Pending'.tr(),
                                          style: const TextStyle(color: Colors.grey),
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
