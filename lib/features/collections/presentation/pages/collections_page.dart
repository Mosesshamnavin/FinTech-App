import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/add_line_modal.dart';
import '../widgets/area_search_modal.dart';

import 'package:go_router/go_router.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  String? _selectedLine;
  String? _selectedArea;
  final TextEditingController _dateController = TextEditingController(text: '16/06/2026');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.wallet, size: 20),
            onPressed: () {
              context.go('/collections/cashout');
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.calculator, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                labelText: 'Date',
                suffixIcon: Padding(
                  padding: EdgeInsets.only(top: 14.0, bottom: 14.0),
                  child: FaIcon(FontAwesomeIcons.calendarDay, color: Colors.lightBlue, size: 20),
                ),
                suffixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 0),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 14.0),
              ),
              isExpanded: true,
              value: _selectedLine,
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.plus, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddLineModal(),
                      );
                    },
                  ),
                ],
              ),
              hint: const Text('Line', style: TextStyle(color: Colors.redAccent)),
              items: ['Main Bazar Line', 'South Street Line', 'Market Line'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedLine = val;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 14.0),
              ),
              isExpanded: true,
              value: _selectedArea,
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, color: Colors.lightBlue, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AreaSearchModal(),
                      );
                    },
                  ),
                ],
              ),
              hint: const Text('Area'),
              items: ['North Zone', 'South Zone', 'East Zone'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedArea = val;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('SUBMIT'),
            ),
          ],
        ),
      ),
    );
  }
}
