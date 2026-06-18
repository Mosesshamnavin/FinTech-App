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
              if (reports[index] == 'Plan') {
                context.go('/reports/plan');
              } else if (reports[index] == 'Daily Summary') {
                context.go('/reports/daily-summary');
              } else if (reports[index] == 'Line Summary') {
                context.go('/reports/line-summary');
              } else if (reports[index] == 'Online Collection Summary') {
                context.go('/reports/online-collection-summary');
              } else if (reports[index] == 'Site Dashboard Summary') {
                context.go('/reports/site-dashboard-summary');
              } else if (reports[index] == 'Expense Summary') {
                context.go('/reports/expense-summary');
              } else if (reports[index] == 'Investment Summary') {
                context.go('/reports/investment-summary');
              } else if (reports[index] == 'Investment/Expense Summary') {
                context.go('/reports/investment-expense-summary');
              } else if (reports[index] == 'Book Excess Loss Summary' || reports[index] == 'Book Excess/Loss Summary') {
                context.go('/reports/book-excess-loss-summary');
              } else if (reports[index] == 'Loan Summary') {
                context.go('/reports/loan-summary');
              } else if (reports[index] == 'About to Close Loan Summary') {
                context.go('/reports/about-to-close-loan-summary');
              } else if (reports[index] == 'Missing Customer Summary') {
                context.go('/reports/missing-customer-summary');
              } else if (reports[index] == 'Monthly Interest Pending Summary') {
                context.go('/reports/monthly-interest-pending-summary');
              } else if (reports[index] == 'Completed Loan Summary') {
                context.go('/reports/completed-loan-summary');
              } else if (reports[index] == 'Non Performance Loan Summary') {
                context.go('/reports/non-performance-loan-summary');
              } else if (reports[index] == 'New Customer Summary') {
                context.go('/reports/new-customer-summary');
              } else if (reports[index] == 'Bad Loan Summary') {
                context.go('/reports/bad-loan-summary');
              } else if (reports[index] == 'New Bad Loan By Date Summary') {
                context.go('/reports/new-bad-loan-by-date-summary');
              } else if (reports[index] == 'Loan Analysis') {
                context.go('/reports/loan-analysis');
              } else if (reports[index] == 'Ledger Report') {
                context.go('/reports/ledger-report');
              } else {
                context.go('/reports/${Uri.encodeComponent(reports[index])}');
              }
            },
          );
        },
      ),
    );
  }
}
