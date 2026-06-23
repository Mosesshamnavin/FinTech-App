import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../bloc/expenses_bloc.dart';
import '../bloc/expenses_event.dart';
import '../bloc/expenses_state.dart';
import '../widgets/add_expense_modal.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> with SingleTickerProviderStateMixin {
  final TextEditingController _fromDateController = TextEditingController(text: '01/06/2026');
  final TextEditingController _toDateController = TextEditingController(text: '16/06/2026');
  String _selectedLine = 'All';
  bool _isOnlineChecked = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadData();
      }
    });

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    _fromDateController.text = DateFormat('dd/MM/yyyy').format(firstDayOfMonth);
    _toDateController.text = DateFormat('dd/MM/yyyy').format(now);
    
    // Initial load for Expense tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final fromFormat = DateFormat('dd/MM/yyyy').parse(_fromDateController.text);
    final toFormat = DateFormat('dd/MM/yyyy').parse(_toDateController.text);
    
    // Tab 0 = Expense (isInvestment = false)
    // Tab 1 = Investment (isInvestment = true)
    final isInvestment = _tabController.index == 1;

    context.read<ExpensesBloc>().add(LoadExpensesRequested(
      from: fromFormat,
      to: toFormat,
      isInvestment: isInvestment,
      lineId: _selectedLine,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      _loadData(); // Reload data when date changes
    }
  }

  void _showAddModal(BuildContext context) {
    final isInvestment = _tabController.index == 1;
    final expensesBloc = context.read<ExpensesBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: expensesBloc,
        child: AddExpenseModal(isInvestment: isInvestment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TabBar(
          controller: _tabController,
          labelColor: Colors.lightBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.lightBlue,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'EXPENSE'),
            Tab(text: 'INVESTMENT'),
          ],
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const FaIcon(FontAwesomeIcons.plus, size: 20),
              onPressed: () => _showAddModal(ctx),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpenseView(false),
          _buildExpenseView(true),
        ],
      ),
    );
  }

  Widget _buildExpenseView(bool isInvestment) {
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
                            _loadData(); // Reload data when line changes
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
          BlocBuilder<ExpensesBloc, ExpensesState>(
            builder: (context, state) {
              if (state is ExpensesLoading) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is ExpensesError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              } else if (state is ExpensesLoaded) {
                // Filter by online/cash switch
                final filtered = state.expenses.where((e) => _isOnlineChecked ? e.isOnline : true).toList();
                
                final totalCash = filtered.where((e) => !e.isOnline).fold(0.0, (sum, e) => sum + e.amount);
                final totalOnline = filtered.where((e) => e.isOnline).fold(0.0, (sum, e) => sum + e.amount);
                final total = totalCash + totalOnline;

                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Date : ${_fromDateController.text} - ${_toDateController.text}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Online: ₹$totalOnline'),
                                Text('Cash: ₹$totalCash'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Total: ₹$total', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final expense = filtered[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: expense.isOnline ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                            child: Icon(
                              expense.isOnline ? Icons.account_balance : Icons.money,
                              color: expense.isOnline ? Colors.blue : Colors.green,
                            ),
                          ),
                          title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${DateFormat('dd MMM yyyy').format(expense.date)} - ${expense.description}'),
                          trailing: Text('₹${expense.amount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                        );
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
