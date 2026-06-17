import 'package:flutter/material.dart';

class SmsTemplatePage extends StatefulWidget {
  const SmsTemplatePage({super.key});

  @override
  State<SmsTemplatePage> createState() => _SmsTemplatePageState();
}

class _SmsTemplatePageState extends State<SmsTemplatePage> with SingleTickerProviderStateMixin {
  bool _isLineTypeOpen = false;
  bool _isFlowOpen = false;
  String _selectedFlow = 'Collection';
  late TabController _tabController;

  List<Map<String, String>> _templateRows = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _updateTemplateRows();
  }

  void _updateTemplateRows() {
    if (_selectedFlow == 'Collection') {
      _templateRows = [
        {'en': '{CustomerName}', 'ta': '{CustomerName}'},
        {'en': 'Today: {AmountPaidToday}', 'ta': 'இன்று: {AmountPaidToday}'},
        {'en': 'Total: {TotalAmount}', 'ta': 'மொத்தம்: {TotalAmount}'},
        {'en': 'Start Date: {TransactionStartDt}', 'ta': 'தேதி: {TransactionStartDt}'},
        {'en': 'Thank you', 'ta': 'நன்றி'},
        {'en': '{FinanceName}', 'ta': '{FinanceName}'},
      ];
    } else if (_selectedFlow == 'Loan Payment') {
      _templateRows = [
        {'en': '{CustomerName}', 'ta': '{CustomerName}'},
        {'en': 'Product: {ProductName}', 'ta': 'பொருள்: {ProductName}'},
        {'en': 'Amount: {Amount}', 'ta': 'அசல்: {Amount}'},
        {'en': 'Interest: {Interest}', 'ta': 'வட்டி: {Interest}'},
        {'en': 'Total: {TotalAmount}', 'ta': 'மொத்தம்: {TotalAmount}'},
        {'en': '{FinanceName}', 'ta': '{FinanceName}'},
      ];
    } else if (_selectedFlow == 'Loan Detail') {
      _templateRows = [
        {'en': '{CustomerName}', 'ta': '{CustomerName}'},
        {'en': 'Product: {ProductName}', 'ta': 'பொருள்: {ProductName}'},
        {'en': 'Amount: {Amount}', 'ta': 'அசல்: {Amount}'},
        {'en': 'Interest: {Interest}', 'ta': 'வட்டி: {Interest}'},
        {'en': 'Total: {TotalAmount}', 'ta': 'மொத்தம்: {TotalAmount}'},
        {'en': 'Start Date: {TransactionStartDt}', 'ta': 'தேதி: {TransactionStartDt}'},
        {'en': '{TransactionHistory}', 'ta': '{TransactionHistory}'},
        {'en': 'Thank you', 'ta': 'நன்றி'},
        {'en': '{FinanceName}', 'ta': '{FinanceName}'},
      ];
    } else {
      _templateRows = [];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDropdownDialog(String label, List<String> options, String currentValue, Function(String) onSelect, VoidCallback onOpen, VoidCallback onClose) async {
    onOpen();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.normal)),
          contentPadding: const EdgeInsets.only(top: 16.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: currentValue,
                  onChanged: (value) {
                    onSelect(value!);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        );
      },
    );
    if (mounted) onClose();
  }

  Widget _buildInteractiveDropdown({
    required String label,
    required bool isOpen,
    required VoidCallback onTap,
    String? displayValue,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: isOpen ? Colors.blue : Colors.grey.shade300, width: isOpen ? 1.5 : 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (displayValue != null)
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.green)),
                Text(
                  displayValue ?? label,
                  style: TextStyle(fontSize: 16, color: isOpen ? Colors.redAccent : Colors.black87),
                ),
              ],
            ),
            Icon(
              isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isOpen ? Colors.redAccent : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header of the card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.drag_handle, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('+ Field', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('BOLD', style: TextStyle(color: Colors.lightBlue)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      _templateRows.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // EN Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const Text('EN', style: TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(width: 32),
                Expanded(
                  child: Text(
                    _templateRows[index]['en'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // TA Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const Text('TA', style: TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(width: 32),
                Expanded(
                  child: Text(
                    _templateRows[index]['ta'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnglishPreview() {
    if (_selectedFlow == 'Collection') {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview (sample data)', style: TextStyle(color: Colors.grey, fontSize: 14)),
          SizedBox(height: 16),
          Text('*Ramesh*', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('*Today: 500*', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Total: 11,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Start Date: 01/01/26', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Thank you', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Demo User', style: TextStyle(color: Colors.black87, fontSize: 15)),
        ],
      );
    } else if (_selectedFlow == 'Loan Detail') {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview (sample data)', style: TextStyle(color: Colors.grey, fontSize: 14)),
          SizedBox(height: 16),
          Text('*Ramesh*', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Product: Gold Chain', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Amount: 10,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Interest: 1,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Total: 11,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Start Date: 01/01/26', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('01) 23/05/26 10:15 - 500', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('02) 22/05/26 09:40 - 500', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('03) 21/05/26 11:05 - 1,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Thank you', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Demo User', style: TextStyle(color: Colors.black87, fontSize: 15)),
        ],
      );
    }
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preview (sample data)', style: TextStyle(color: Colors.grey, fontSize: 14)),
        SizedBox(height: 16),
        Text('*Ramesh*', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('Product: Gold Chain', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('Amount: 10,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('Interest: 1,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('Total: 11,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('Start Date: 01/01/26', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('01) 23/05/26 10:15 - 500', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('02) 22/05/26 09:40 - 500', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('03) 21/05/26 11:05 - 1,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('Thank you', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('Demo User', style: TextStyle(color: Colors.black87, fontSize: 15)),
      ],
    );
  }

  Widget _buildTamilPreview() {
    if (_selectedFlow == 'Collection') {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview (sample data)', style: TextStyle(color: Colors.grey, fontSize: 14)),
          SizedBox(height: 16),
          Text('*Ramesh*', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('*இன்று: 500*', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('மொத்தம்: 11,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('தேதி: 01/01/26', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('நன்றி', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Demo User', style: TextStyle(color: Colors.black87, fontSize: 15)),
        ],
      );
    } else if (_selectedFlow == 'Loan Detail') {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview (sample data)', style: TextStyle(color: Colors.grey, fontSize: 14)),
          SizedBox(height: 16),
          Text('*Ramesh*', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('பொருள்: Gold Chain', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('அசல்: 10,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('வட்டி: 1,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('மொத்தம்: 11,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('தேதி: 01/01/26', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('01) 23/05/26 10:15 - 500', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('02) 22/05/26 09:40 - 500', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('03) 21/05/26 11:05 - 1,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('நன்றி', style: TextStyle(color: Colors.black87, fontSize: 15)),
          SizedBox(height: 4),
          Text('Demo User', style: TextStyle(color: Colors.black87, fontSize: 15)),
        ],
      );
    }
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preview (sample data)', style: TextStyle(color: Colors.grey, fontSize: 14)),
        SizedBox(height: 16),
        Text('*Ramesh*', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('பொருள்: Gold Chain', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('அசல்: 10,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('வட்டி: 1,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('மொத்தம்: 11,000', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('தேதி: 01/01/26', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('நன்றி', style: TextStyle(color: Colors.black87, fontSize: 15)),
        SizedBox(height: 4),
        Text('Demo User', style: TextStyle(color: Colors.black87, fontSize: 15)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Template'),
        elevation: 2,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInteractiveDropdown(
                label: 'Line Type',
                isOpen: _isLineTypeOpen,
                onTap: () {
                  setState(() => _isLineTypeOpen = true);
                  // Mock dialog
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) setState(() => _isLineTypeOpen = false);
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildInteractiveDropdown(
                label: 'Flow',
                displayValue: _selectedFlow,
                isOpen: _isFlowOpen,
                onTap: () {
                  _showDropdownDialog(
                    'Flow',
                    ['Loan Payment', 'Collection', 'Loan Detail'],
                    _selectedFlow,
                    (val) => setState(() => _selectedFlow = val),
                    () => setState(() => _isFlowOpen = true),
                    () => setState(() => _isFlowOpen = false),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Type any text and tap + Field to drop a field where the cursor is — so one line can mix several fields with your own separators, e.g. Next Due: {NextDueAmount} / {NextDueDate}. Use Bold to bold the whole line for WhatsApp, or wrap part of a line in *stars* to bold just that part. An empty row makes a blank line.',
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              
              // Template Rows
              ...List.generate(_templateRows.length, (index) => _buildTemplateRow(index)),

              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.lightBlue),
                      label: const Text('ADD ROW', style: TextStyle(color: Colors.lightBlue)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.lightBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.remove, color: Colors.lightBlue),
                      label: const Text('ADD BLANK LINE', style: TextStyle(color: Colors.lightBlue)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.lightBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Preview line', style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      const Text('Select a line', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Preview Tabs
              TabBar(
                controller: _tabController,
                labelColor: Colors.lightBlue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.lightBlue,
                tabs: const [
                  Tab(text: 'ENGLISH'),
                  Tab(text: 'தமிழ்'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _tabController.index == 0 ? _buildEnglishPreview() : _buildTamilPreview(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('SAVE TEMPLATE', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
