import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';
import 'dart:convert';

class SmsTemplatePage extends StatefulWidget {
  const SmsTemplatePage({super.key});

  @override
  State<SmsTemplatePage> createState() => _SmsTemplatePageState();
}

class _SmsTemplatePageState extends State<SmsTemplatePage> with SingleTickerProviderStateMixin {
  final StorageService _storageService = sl<StorageService>();
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
    _loadTemplates();
  }

  void _loadTemplates() {
    final key = 'sms_template_$_selectedFlow';
    final savedJson = _storageService.getString(key);
    if (savedJson.isNotEmpty) {
      try {
        final List decoded = json.decode(savedJson);
        setState(() {
          _templateRows = decoded.map<Map<String, String>>((item) {
            return {
              'id': item['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
              'en': item['en']?.toString() ?? '',
              'ta': item['ta']?.toString() ?? '',
            };
          }).toList();
        });
        return;
      } catch (_) {
        // Fallback to default
      }
    }
    _loadDefaultTemplates();
  }

  void _loadDefaultTemplates() {
    setState(() {
      if (_selectedFlow == 'Collection') {
        _templateRows = [
          {'id': '1', 'en': '{CustomerName}', 'ta': '{CustomerName}'},
          {'id': '2', 'en': 'Today: {AmountPaidToday}', 'ta': 'இன்று: {AmountPaidToday}'},
          {'id': '3', 'en': 'Total: {TotalAmount}', 'ta': 'மொத்தம்: {TotalAmount}'},
          {'id': '4', 'en': 'Start Date: {TransactionStartDt}', 'ta': 'தேதி: {TransactionStartDt}'},
          {'id': '5', 'en': 'Thank you', 'ta': 'நன்றி'},
          {'id': '6', 'en': '{FinanceName}', 'ta': '{FinanceName}'},
        ];
      } else if (_selectedFlow == 'Loan Payment') {
        _templateRows = [
          {'id': '1', 'en': '{CustomerName}', 'ta': '{CustomerName}'},
          {'id': '2', 'en': 'Product: {ProductName}', 'ta': 'பொருள்: {ProductName}'},
          {'id': '3', 'en': 'Amount: {Amount}', 'ta': 'அசல்: {Amount}'},
          {'id': '4', 'en': 'Interest: {Interest}', 'ta': 'வட்டி: {Interest}'},
          {'id': '5', 'en': 'Total: {TotalAmount}', 'ta': 'மொத்தம்: {TotalAmount}'},
          {'id': '6', 'en': '{FinanceName}', 'ta': '{FinanceName}'},
        ];
      } else if (_selectedFlow == 'Loan Detail') {
        _templateRows = [
          {'id': '1', 'en': '{CustomerName}', 'ta': '{CustomerName}'},
          {'id': '2', 'en': 'Product: {ProductName}', 'ta': 'பொருள்: {ProductName}'},
          {'id': '3', 'en': 'Amount: {Amount}', 'ta': 'அசல்: {Amount}'},
          {'id': '4', 'en': 'Interest: {Interest}', 'ta': 'வட்டி: {Interest}'},
          {'id': '5', 'en': 'Total: {TotalAmount}', 'ta': 'மொத்தம்: {TotalAmount}'},
          {'id': '6', 'en': 'Start Date: {TransactionStartDt}', 'ta': 'தேதி: {TransactionStartDt}'},
          {'id': '7', 'en': '{TransactionHistory}', 'ta': '{TransactionHistory}'},
          {'id': '8', 'en': 'Thank you', 'ta': 'நன்றி'},
          {'id': '9', 'en': '{FinanceName}', 'ta': '{FinanceName}'},
        ];
      } else {
        _templateRows = [];
      }
    });
  }

  Future<void> _saveTemplates() async {
    final key = 'sms_template_$_selectedFlow';
    final jsonStr = json.encode(_templateRows);
    await _storageService.setString(key, jsonStr);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template saved successfully!')),
      );
    }
  }

  void _showFieldSelector(int index) {
    final fields = [
      '{CustomerName}',
      '{AmountPaidToday}',
      '{TotalAmount}',
      '{TransactionStartDt}',
      '{FinanceName}',
      '{ProductName}',
      '{Amount}',
      '{Interest}',
      '{TransactionHistory}',
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insert Field'),
          contentPadding: const EdgeInsets.only(top: 16.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields.map((field) {
                return ListTile(
                  title: Text(field),
                  onTap: () {
                    setState(() {
                      _templateRows[index]['en'] = (_templateRows[index]['en'] ?? '') + field;
                      _templateRows[index]['ta'] = (_templateRows[index]['ta'] ?? '') + field;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
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
                  style: TextStyle(fontSize: 16, color: isOpen ? Colors.redAccent : Theme.of(context).colorScheme.onSurface),
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
      key: ValueKey(_templateRows[index]['id'] ?? index.toString()),
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                GestureDetector(
                  onTap: () => _showFieldSelector(index),
                  child: const Row(
                    children: [
                      Text('+ Field', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      final en = _templateRows[index]['en'] ?? '';
                      final ta = _templateRows[index]['ta'] ?? '';
                      if (en.isNotEmpty && !en.startsWith('*') && !en.endsWith('*')) {
                        _templateRows[index]['en'] = '*$en*';
                      }
                      if (ta.isNotEmpty && !ta.startsWith('*') && !ta.endsWith('*')) {
                        _templateRows[index]['ta'] = '*$ta*';
                      }
                    });
                  },
                  child: Text('BOLD', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                Text('EN', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(width: 32),
                Expanded(
                  child: TextFormField(
                    initialValue: _templateRows[index]['en'] ?? '',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter English text...',
                    ),
                    onChanged: (val) {
                      _templateRows[index]['en'] = val;
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // TA Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                Text('TA', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(width: 32),
                Expanded(
                  child: TextFormField(
                    initialValue: _templateRows[index]['ta'] ?? '',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Tamil text...',
                    ),
                    onChanged: (val) {
                      _templateRows[index]['ta'] = val;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _replacePlaceholders(String text) {
    return text
        .replaceAll('{CustomerName}', '*Vijay Kumar*')
        .replaceAll('{AmountPaidToday}', '*500*')
        .replaceAll('{TotalAmount}', '11,000')
        .replaceAll('{TransactionStartDt}', '01/01/2026')
        .replaceAll('{FinanceName}', 'Vasool Drive')
        .replaceAll('{ProductName}', 'Gold Chain')
        .replaceAll('{Amount}', '10,000')
        .replaceAll('{Interest}', '1,000')
        .replaceAll('{TransactionHistory}', '01) 23/05/26 10:15 - 500\n02) 22/05/26 09:40 - 500\n03) 21/05/26 11:05 - 1,000');
  }

  Widget _buildEnglishPreview() {
    final previewText = _templateRows
        .map((row) => _replacePlaceholders(row['en'] ?? ''))
        .join('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preview (sample data)', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 16),
        Text(previewText.isEmpty ? '(Empty Template)' : previewText,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15)),
      ],
    );
  }

  Widget _buildTamilPreview() {
    final previewText = _templateRows
        .map((row) => _replacePlaceholders(row['ta'] ?? ''))
        .join('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preview (sample data)', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 16),
        Text(previewText.isEmpty ? '(Empty Template)' : previewText,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15)),
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
                    (val) {
                      setState(() => _selectedFlow = val);
                      _loadTemplates();
                    },
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
                      onPressed: () {
                        setState(() {
                          _templateRows.add({
                            'id': DateTime.now().microsecondsSinceEpoch.toString(),
                            'en': '',
                            'ta': '',
                          });
                        });
                      },
                      icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                      label: Text('ADD ROW', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _templateRows.add({
                            'id': DateTime.now().microsecondsSinceEpoch.toString(),
                            'en': '',
                            'ta': '',
                          });
                        });
                      },
                      icon: Icon(Icons.remove, color: Theme.of(context).colorScheme.primary),
                      label: Text('ADD BLANK LINE', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
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
                      Text('Preview Tab', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Preview Tabs
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _tabController.index == 0 ? _buildEnglishPreview() : _buildTamilPreview(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTemplates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
