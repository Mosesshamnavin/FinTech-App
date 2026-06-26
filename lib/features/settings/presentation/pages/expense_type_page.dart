import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_state.dart';
import '../bloc/settings_event.dart';
import '../../domain/entities/settings_entities.dart';

class ExpenseTypePage extends StatelessWidget {
  const ExpenseTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Type'),
        elevation: 2,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () {
              context.push('/settings/add-expense-type');
            },
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else if (state is SettingsLoaded) {
            if (state.expenseTypes.isEmpty) {
              return const Center(child: Text('No Expense Types found.'));
            }
            return ListView.separated(
              itemCount: state.expenseTypes.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final type = state.expenseTypes[index];
                return ListTile(
                  title: Text(type.name, style: const TextStyle(fontSize: 16)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.isActive ? 'Active' : 'InActive',
                        style: TextStyle(
                          color: type.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(context, type);
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, type);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, ExpenseTypeEntity type) {
    final nameController = TextEditingController(text: type.name);
    String status = type.isActive ? 'Active' : 'InActive';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit Expense Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Active', 'InActive'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => status = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final updated = ExpenseTypeEntity(
                    id: type.id,
                    name: nameController.text.trim(),
                    isActive: status == 'Active',
                  );
                  context.read<SettingsBloc>().add(UpdateExpenseTypeSubmitted(updated));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseTypeEntity type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense Type'),
        content: Text('Are you sure you want to delete "${type.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              context.read<SettingsBloc>().add(DeleteExpenseTypeSubmitted(type.id));
              Navigator.pop(ctx);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
