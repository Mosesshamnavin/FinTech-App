import 'package:flutter/material.dart';

class ExportLinePage extends StatefulWidget {
  const ExportLinePage({super.key});

  @override
  State<ExportLinePage> createState() => _ExportLinePageState();
}

class _ExportLinePageState extends State<ExportLinePage> {
  // Download Tab State
  bool _isLineTypeOpen = false;
  bool _isLineOpen = false;
  String _selectedOrientation = 'Portrait';
  bool _isColumnsOpen = false;
  int _selectedColumns = 7;
  bool _groupCustomerByArea = true;

  // Export Tab State
  bool _isExportLineTypeOpen = false;
  bool _isExportLineOpen = false;
  bool _isAllLines = true;
  bool _isExportFieldsExpanded = false;

  // Export fields state
  final Map<String, bool> _exportFields = {
    'CustomerOrder': true,
    'CustomerName': true,
    'CustomerCode': true,
    'CustomerSubCode': true,
    'MobileNumber': true,
    'StatusMessage': true,
    'TransactionStartDt': true,
    'LastPaymentDate': true,
    'NoOfInstall': true,
    'Amount': true,
    'Interest': true,
    'BillAmount': true,
    'TotalAmount': true,
    'TotalAmountPaid': true,
    'TotalAmountPayable': true,
  };

  void _showDropdownDialog(String label, VoidCallback onOpen, VoidCallback onClose) async {
    onOpen();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.normal)),
          contentPadding: const EdgeInsets.only(top: 24.0, bottom: 0.0),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.cyan)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        );
      },
    );
    if (mounted) onClose();
  }

  void _showColumnsDialog() async {
    setState(() => _isColumnsOpen = true);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Blank Columns', style: TextStyle(fontWeight: FontWeight.normal)),
          contentPadding: const EdgeInsets.only(top: 16.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [5, 6, 7, 8, 9, 10].map((int val) {
                return RadioListTile<int>(
                  title: Text(val.toString()),
                  value: val,
                  groupValue: _selectedColumns,
                  onChanged: (value) {
                    setState(() {
                      _selectedColumns = value!;
                    });
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        );
      },
    );
    if (mounted) setState(() => _isColumnsOpen = false);
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Export Line'),
          elevation: 2,
          shadowColor: Colors.black26,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            tabs: [
              Tab(text: 'DOWNLOAD'),
              Tab(text: 'EXPORT'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // DOWNLOAD TAB
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInteractiveDropdown(
                    label: 'Line Type',
                    isOpen: _isLineTypeOpen,
                    onTap: () => _showDropdownDialog('Line Type', () => setState(() => _isLineTypeOpen = true), () => setState(() => _isLineTypeOpen = false)),
                  ),
                  const SizedBox(height: 8),
                  _buildInteractiveDropdown(
                    label: 'Line',
                    isOpen: _isLineOpen,
                    onTap: () => _showDropdownDialog('Line', () => setState(() => _isLineOpen = true), () => setState(() => _isLineOpen = false)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Portrait', style: TextStyle(fontSize: 16)),
                            value: 'Portrait',
                            groupValue: _selectedOrientation,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setState(() => _selectedOrientation = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Landscape', style: TextStyle(fontSize: 16)),
                            value: 'Landscape',
                            groupValue: _selectedOrientation,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setState(() => _selectedOrientation = val!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInteractiveDropdown(
                    label: 'Blank Columns',
                    displayValue: '$_selectedColumns',
                    isOpen: _isColumnsOpen,
                    onTap: _showColumnsDialog,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Can group customer by area?', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: _groupCustomerByArea,
                          onChanged: (val) => setState(() => _groupCustomerByArea = val),
                          activeColor: Colors.lightBlue,
                        ),
                      ],
                    ),
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
                    child: const Text('DOWNLOAD PDF', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),

            // EXPORT TAB
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInteractiveDropdown(
                    label: 'Line Type',
                    isOpen: _isExportLineTypeOpen,
                    onTap: () => _showDropdownDialog('Line Type', () => setState(() => _isExportLineTypeOpen = true), () => setState(() => _isExportLineTypeOpen = false)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showDropdownDialog('Line', () => setState(() => _isExportLineOpen = true), () => setState(() => _isExportLineOpen = false)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Line', style: TextStyle(fontSize: 16, color: _isExportLineOpen ? Colors.redAccent : Colors.black87)),
                                Icon(_isExportLineOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: _isExportLineOpen ? Colors.redAccent : Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _isAllLines,
                              onChanged: (val) => setState(() => _isAllLines = val!),
                              activeColor: Colors.lightBlue,
                            ),
                            const Text('All', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Email ID',
                      labelStyle: TextStyle(fontSize: 12),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    ),
                    controller: TextEditingController(text: 'admin@gmail.com'),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade50),
                    child: ExpansionTile(
                      title: const Text('Export Fields', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      iconColor: Colors.black,
                      collapsedIconColor: Colors.black,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isExportFieldsExpanded = expanded;
                        });
                      },
                      children: [
                        Container(
                          color: Colors.white,
                          child: Column(
                            children: _exportFields.keys.map((String key) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                ),
                                child: SwitchListTile(
                                  title: Text(key),
                                  value: _exportFields[key]!,
                                  onChanged: (val) {
                                    setState(() {
                                      _exportFields[key] = val;
                                    });
                                  },
                                  activeColor: Colors.lightBlue,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
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
                    child: const Text('SEND MAIL(EXCEL)', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
