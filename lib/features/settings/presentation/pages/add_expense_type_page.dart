import 'package:flutter/material.dart';

class AddExpenseTypePage extends StatefulWidget {
  const AddExpenseTypePage({super.key});

  @override
  State<AddExpenseTypePage> createState() => _AddExpenseTypePageState();
}

class _AddExpenseTypePageState extends State<AddExpenseTypePage> {
  String _status = 'Active';

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
        title: const Text('Add Expense Type'),
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
            const TextField(
              decoration: InputDecoration(
                labelText: 'Expense Type Name',
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
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Save logic
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
