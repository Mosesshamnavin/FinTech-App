import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      body: const SizedBox.shrink(), // Empty body as per screenshot
    );
  }
}
