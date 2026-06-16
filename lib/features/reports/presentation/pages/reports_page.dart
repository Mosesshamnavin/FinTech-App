import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> reports = [
      'Plan',
      'Daily Summary',
      'Line Summary',
      'Online Collection Summary',
      'Site Dashboard Summary',
      'Expense Summary',
      'Investment Summary',
      'Investment/Expense Summary',
      'Book Excess Loss Summary',
      'Loan Summary',
      'About to Close Loan Summary',
      'Missing Customer Summary',
      'Monthly Interest Pending Summary',
      'Completed Loan Summary',
      'Non Performance Loan Summary',
      'New Customer Summary',
      'Bad Loan Summary',
      'New Bad Loan By Date Summary',
      'Loan Analysis',
      'Ledger Report',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        elevation: 2,
        shadowColor: Colors.black45,
      ),
      body: ListView.separated(
        itemCount: reports.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            title: Text(
              reports[index],
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () {
              context.go('/reports/${Uri.encodeComponent(reports[index])}');
            },
          );
        },
      ),
    );
  }
}
