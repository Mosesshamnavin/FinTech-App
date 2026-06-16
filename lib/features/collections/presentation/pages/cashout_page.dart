import 'package:flutter/material.dart';

import '../widgets/add_cashout_modal.dart';

class CashOutPage extends StatefulWidget {
  const CashOutPage({super.key});

  @override
  State<CashOutPage> createState() => _CashOutPageState();
}

class _CashOutPageState extends State<CashOutPage> {
  String _selectedLine = 'All';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CashOut'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, size: 28),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddCashOutModal(),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            tabs: [
              Tab(text: 'ACTIVE'),
              Tab(text: 'HISTORY'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Line',
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                ),
                isExpanded: true,
                value: _selectedLine,
                items: ['All', 'Main Bazar Line', 'South Street Line'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedLine = val;
                    });
                  }
                },
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text('Active View')),
                  Center(child: Text('History View')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
