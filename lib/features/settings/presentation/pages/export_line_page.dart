import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/datasources/settings_remote_datasource.dart';
import '../../data/services/csv_helper.dart';
import '../../domain/entities/settings_entities.dart';

class ExportLinePage extends StatefulWidget {
  const ExportLinePage({super.key});

  @override
  State<ExportLinePage> createState() => _ExportLinePageState();
}

class _ExportLinePageState extends State<ExportLinePage> {
  // Lines list
  List<LineEntity> _lines = [];
  bool _isFetchingLines = false;

  // Selected filters
  String? _selectedTypeDownload;
  String? _selectedTypeExport;
  LineEntity? _selectedLineDownload;
  LineEntity? _selectedLineExport;

  // Dropdown states
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
  bool _isExporting = false;

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

  @override
  void initState() {
    super.initState();
    _loadLines();
  }

  Future<void> _loadLines() async {
    setState(() => _isFetchingLines = true);
    try {
      final lines = await sl<SettingsRemoteDataSource>().getLines();
      setState(() {
        _lines = lines;
        if (_lines.isNotEmpty) {
          _selectedLineDownload = _lines.first;
          _selectedLineExport = _lines.first;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lines: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLines = false);
    }
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
    if (mounted) setState(() => _isColumnsOpen = false);
  }

  void _showLineSelectionDialog({required bool isDownloadTab}) async {
    final filteredLines = _lines.where((l) {
      final filterType = isDownloadTab ? _selectedTypeDownload : _selectedTypeExport;
      return filterType == null || l.type == filterType;
    }).toList();

    if (filteredLines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No lines available for selected type.')),
      );
      return;
    }

    if (isDownloadTab) {
      setState(() => _isLineOpen = true);
    } else {
      setState(() => _isExportLineOpen = true);
    }

    final currentSelected = isDownloadTab ? _selectedLineDownload : _selectedLineExport;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Line', style: TextStyle(fontWeight: FontWeight.normal)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: filteredLines.map((line) {
                return RadioListTile<LineEntity>(
                  title: Text(line.name),
                  value: line,
                  groupValue: currentSelected,
                  onChanged: (value) {
                    setState(() {
                      if (isDownloadTab) {
                        _selectedLineDownload = value;
                      } else {
                        _selectedLineExport = value;
                      }
                    });
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

    if (mounted) {
      setState(() {
        _isLineOpen = false;
        _isExportLineOpen = false;
      });
    }
  }

  void _showTypeSelectionDialog({required bool isDownloadTab}) async {
    final types = ['All', ..._lines.map((l) => l.type).toSet().toList()];

    if (isDownloadTab) {
      setState(() => _isLineTypeOpen = true);
    } else {
      setState(() => _isExportLineTypeOpen = true);
    }

    final currentSelected = isDownloadTab ? (_selectedTypeDownload ?? 'All') : (_selectedTypeExport ?? 'All');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Line Type', style: TextStyle(fontWeight: FontWeight.normal)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: types.map((type) {
                return RadioListTile<String>(
                  title: Text(type),
                  value: type,
                  groupValue: currentSelected,
                  onChanged: (value) {
                    setState(() {
                      final selectedVal = value == 'All' ? null : value;
                      if (isDownloadTab) {
                        _selectedTypeDownload = selectedVal;
                      } else {
                        _selectedTypeExport = selectedVal;
                      }
                    });
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

    if (mounted) {
      setState(() {
        _isLineTypeOpen = false;
        _isExportLineTypeOpen = false;
      });
    }
  }

  Future<void> _exportCsv() async {
    if (!_isAllLines && _selectedLineExport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a line to export.')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final client = sl<GraphQLClient>();
      
      // Determine line filter
      Map<String, dynamic> whereClause = {};
      if (!_isAllLines && _selectedLineExport != null) {
        whereClause['line_id'] = {'_eq': _selectedLineExport!.id};
      }

      const String query = '''
        query GetExportData(\$where: customers_bool_exp!) {
          customers(where: \$where) {
            id
            name
            phone
            line_id
            area_id
            created_at
            loans(order_by: {created_at: desc}) {
              id
              principal_amount
              interest_amount
              total_amount
              daily_due_amount
              outstanding_balance
              start_date
              end_date
              status
              created_at
            }
            collections(order_by: {date: desc}) {
              amount
              status
              date
            }
          }
        }
      ''';

      final result = await client.query(QueryOptions(
        document: gql(query),
        variables: {'where': whereClause},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List customersData = result.data?['customers'] ?? [];
      
      if (customersData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No customer records found to export.')),
          );
        }
        return;
      }

      // Generate headers based on selected fields
      final headers = _exportFields.keys.where((k) => _exportFields[k] == true).toList();
      final List<Map<String, String>> rows = [];

      for (int i = 0; i < customersData.length; i++) {
        final customer = customersData[i];
        final List loans = customer['loans'] ?? [];
        final List collections = customer['collections'] ?? [];

        // Calculate total amount paid
        final double totalPaid = collections
            .where((c) => c['status'] == 'paid')
            .fold(0.0, (sum, c) => sum + (double.tryParse(c['amount']?.toString() ?? '0') ?? 0.0));

        // Get latest loan or create dummy empty structure
        final latestLoan = loans.isNotEmpty ? loans.first : null;

        final Map<String, String> row = {};
        row['CustomerOrder'] = '${i + 1}';
        row['CustomerName'] = customer['name']?.toString() ?? '';
        row['CustomerCode'] = customer['id']?.toString() ?? '';
        row['CustomerSubCode'] = customer['id'] != null ? customer['id'].toString().substring(0, 8) : '';
        row['MobileNumber'] = customer['phone']?.toString() ?? '';
        row['StatusMessage'] = (latestLoan != null ? latestLoan['status']?.toString() : 'No Loan') ?? 'No Loan';
        row['TransactionStartDt'] = (latestLoan != null ? latestLoan['start_date']?.toString() : '') ?? '';
        row['LastPaymentDate'] = (collections.isNotEmpty ? collections.first['date']?.toString() : '') ?? '';
        
        // No of Install from line definition
        final lineId = customer['line_id']?.toString();
        final line = _lines.firstWhere((l) => l.id == lineId, orElse: () => LineEntity(
          id: '',
          name: '',
          type: '',
          interestPerHundred: 0.0,
          billAmountPerHundred: 0.0,
          noOfInstall: 100,
          badLoanDays: 0,
          closeLoanManually: false,
          enablePenalty: false,
          keepPaidCustomer: false,
        ));
        row['NoOfInstall'] = '${line.noOfInstall}';

        row['Amount'] = latestLoan != null ? latestLoan['principal_amount']?.toString() ?? '0' : '0';
        row['Interest'] = latestLoan != null ? latestLoan['interest_amount']?.toString() ?? '0' : '0';
        row['BillAmount'] = latestLoan != null ? latestLoan['daily_due_amount']?.toString() ?? '0' : '0';
        row['TotalAmount'] = latestLoan != null ? latestLoan['total_amount']?.toString() ?? '0' : '0';
        row['TotalAmountPaid'] = '$totalPaid';
        
        final double outstanding = latestLoan != null 
            ? (double.tryParse(latestLoan['outstanding_balance']?.toString() ?? '0') ?? 0.0) 
            : 0.0;
        row['TotalAmountPayable'] = '$outstanding';

        rows.add(row);
      }

      final csvContent = CsvHelper.toCsv(headers: headers, rows: rows);
      final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final String filename = 'line_export_${_isAllLines ? "all" : (_selectedLineExport?.name ?? "line")}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$filename');
      await file.writeAsString(csvContent);

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Export Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Line data successfully exported to CSV!'),
                const SizedBox(height: 16),
                const Text('Saved Location:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                SelectableText(
                  file.path,
                  style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
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
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'DOWNLOAD'),
              Tab(text: 'EXPORT'),
            ],
          ),
        ),
        body: _isFetchingLines
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
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
                          displayValue: _selectedTypeDownload ?? 'All',
                          onTap: () => _showTypeSelectionDialog(isDownloadTab: true),
                        ),
                        const SizedBox(height: 8),
                        _buildInteractiveDropdown(
                          label: 'Line',
                          isOpen: _isLineOpen,
                          displayValue: _selectedLineDownload?.name ?? 'None Selected',
                          onTap: () => _showLineSelectionDialog(isDownloadTab: true),
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
                                activeColor: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('PDF generation coming soon! Please use the EXPORT tab for CSV.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                          displayValue: _selectedTypeExport ?? 'All',
                          onTap: () => _showTypeSelectionDialog(isDownloadTab: false),
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
                                  onTap: _isAllLines ? null : () => _showLineSelectionDialog(isDownloadTab: false),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _isAllLines ? 'All Lines selected' : (_selectedLineExport?.name ?? 'Line'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _isAllLines
                                              ? Colors.grey
                                              : (_isExportLineOpen ? Colors.redAccent : Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ),
                                      Icon(
                                        _isExportLineOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                        color: _isAllLines ? Colors.grey : (_isExportLineOpen ? Colors.redAccent : Colors.grey),
                                      ),
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
                                    activeColor: Theme.of(context).colorScheme.primary,
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
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                          child: ExpansionTile(
                            title: Text('Export Fields', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                            iconColor: Theme.of(context).colorScheme.onSurface,
                            collapsedIconColor: Theme.of(context).colorScheme.onSurface,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _isExportFieldsExpanded = expanded;
                              });
                            },
                            children: [
                              Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: Column(
                                  children: _exportFields.keys.map((String key) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                                      ),
                                      child: SwitchListTile(
                                        title: Text(key),
                                        value: _exportFields[key]!,
                                        onChanged: (val) {
                                          setState(() {
                                            _exportFields[key] = val;
                                          });
                                        },
                                        activeColor: Theme.of(context).colorScheme.primary,
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
                        _isExporting
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _exportCsv,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('EXPORT TO CSV', style: TextStyle(fontSize: 16)),
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
