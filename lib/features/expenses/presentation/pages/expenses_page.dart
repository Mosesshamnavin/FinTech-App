import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final TextEditingController _fromDateController = TextEditingController(text: '01/06/2026');
  final TextEditingController _toDateController = TextEditingController(text: '16/06/2026');
  String _selectedLine = 'All';
  bool _isOnlineChecked = false;

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'EXPENSE'),
              Tab(text: 'INVESTMENT'),
            ],
          ),
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.plus, size: 20),
              onPressed: () {},
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildExpenseView(),
            _buildExpenseView(), // Investment view is identical to Expense view
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 12.0),
                  child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 18, color: Colors.grey),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('Search By Date', style: TextStyle(fontWeight: FontWeight.bold)),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _fromDateController,
                        readOnly: true,
                        onTap: () => _selectDate(context, _fromDateController),
                        decoration: const InputDecoration(
                          labelText: 'From Date',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(top: 14.0, bottom: 14.0),
                            child: FaIcon(FontAwesomeIcons.calendarDay, color: Colors.lightBlue, size: 20),
                          ),
                          suffixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 0),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        ),
                      ),
                      TextField(
                        controller: _toDateController,
                        readOnly: true,
                        onTap: () => _selectDate(context, _toDateController),
                        decoration: const InputDecoration(
                          labelText: 'To Date',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(top: 14.0, bottom: 14.0),
                            child: FaIcon(FontAwesomeIcons.calendarDay, color: Colors.lightBlue, size: 20),
                          ),
                          suffixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 0),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Line',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          CheckboxListTile(
            title: const Text('Online'),
            value: _isOnlineChecked,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _isOnlineChecked = val;
                });
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Date : ${_fromDateController.text} - ${_toDateController.text}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Online: 0'),
                      Text('Cash: 0'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Total: 0', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
