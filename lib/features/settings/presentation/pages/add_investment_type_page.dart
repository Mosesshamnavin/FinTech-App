import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/settings_entities.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';

class AddInvestmentTypePage extends StatefulWidget {
  const AddInvestmentTypePage({super.key});

  @override
  State<AddInvestmentTypePage> createState() => _AddInvestmentTypePageState();
}

class _AddInvestmentTypePageState extends State<AddInvestmentTypePage> {
  final TextEditingController _nameController = TextEditingController();
  String _status = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  bool _trackInvestment = false;

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempStatus = _status;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Status'),
              contentPadding: const EdgeInsets.only(top: 16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Active'),
                    value: 'Active',
                    groupValue: tempStatus,
                    onChanged: (value) {
                      setState(() {
                        tempStatus = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('InActive'),
                    value: 'InActive',
                    groupValue: tempStatus,
                    onChanged: (value) {
                      setState(() {
                        tempStatus = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      _status = tempStatus;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Investment Type'),
        elevation: 2,
        shadowColor: Colors.black26,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Investment Type Name',
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _showStatusDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        const SizedBox(height: 4),
                        Text(_status, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Track Investment', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _trackInvestment,
                    onChanged: (value) {
                      setState(() {
                        _trackInvestment = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name')));
                    return;
                  }
                  final newInvestmentType = InvestmentTypeEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text.trim(),
                    isActive: _status == 'Active',
                  );
                  context.read<SettingsBloc>().add(AddInvestmentTypeSubmitted(newInvestmentType));
                  Navigator.of(context).pop();
                },
                child: const Text('SAVE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
