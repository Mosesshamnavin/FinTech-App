import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/datasources/settings_remote_datasource.dart';
import '../../data/services/csv_helper.dart';
import '../../domain/entities/settings_entities.dart';

class ImportLinePage extends StatefulWidget {
  const ImportLinePage({super.key});

  @override
  State<ImportLinePage> createState() => _ImportLinePageState();
}

class _ImportLinePageState extends State<ImportLinePage> {
  // Lines list
  List<LineEntity> _lines = [];
  bool _isFetchingLines = false;
  LineEntity? _selectedLine;
  bool _isLineOpen = false;

  // CSV list files scan
  List<FileSystemEntity> _csvFiles = [];
  FileSystemEntity? _selectedFile;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadLines();
    _scanForCsvFiles();
  }

  Future<void> _loadLines() async {
    setState(() => _isFetchingLines = true);
    try {
      final lines = await sl<SettingsRemoteDataSource>().getLines();
      setState(() {
        _lines = lines;
        if (_lines.isNotEmpty) {
          _selectedLine = _lines.first;
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

  Future<void> _scanForCsvFiles() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final extDir = await getExternalStorageDirectory();
      
      final List<FileSystemEntity> files = [];
      if (await docDir.exists()) {
        files.addAll(docDir.listSync().where((f) => f.path.endsWith('.csv')));
      }
      if (extDir != null && await extDir.exists()) {
        files.addAll(extDir.listSync().where((f) => f.path.endsWith('.csv')));
      }
      
      setState(() {
        _csvFiles = files;
        if (_csvFiles.isNotEmpty) {
          _selectedFile = _csvFiles.first;
        } else {
          _selectedFile = null;
        }
      });
    } catch (e) {
      print('Error scanning files: $e');
    }
  }

  void _showLineDialog() async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No lines available.')),
      );
      return;
    }

    setState(() => _isLineOpen = true);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Line', style: TextStyle(fontWeight: FontWeight.normal)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _lines.map((line) {
                return RadioListTile<LineEntity>(
                  title: Text(line.name),
                  value: line,
                  groupValue: _selectedLine,
                  onChanged: (value) {
                    setState(() {
                      _selectedLine = value;
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
      setState(() => _isLineOpen = false);
    }
  }

  Future<void> _downloadSampleCsv() async {
    try {
      final headers = [
        'CustomerName',
        'Amount',
        'Interest',
        'BillAmount',
        'NoOfInstall',
        'TransactionStartDt',
        'TotalAmountPaid',
        'CustomerCode',
        'MobileNumber',
        'Address',
        'CustomerOrder'
      ];
      final rows = [
        {
          'CustomerName': 'John Doe',
          'Amount': '10000',
          'Interest': '1000',
          'BillAmount': '110',
          'NoOfInstall': '100',
          'TransactionStartDt': DateTime.now().toIso8601String().split('T')[0],
          'TotalAmountPaid': '1100',
          'CustomerCode': 'CUST-A1',
          'MobileNumber': '9876543210',
          'Address': 'Sample Address',
          'CustomerOrder': '1',
        },
        {
          'CustomerName': 'Jane Smith',
          'Amount': '5000',
          'Interest': '500',
          'BillAmount': '55',
          'NoOfInstall': '100',
          'TransactionStartDt': DateTime.now().toIso8601String().split('T')[0],
          'TotalAmountPaid': '0',
          'CustomerCode': 'CUST-A2',
          'MobileNumber': '9876543211',
          'Address': 'Another Address',
          'CustomerOrder': '2',
        }
      ];
      final csvContent = CsvHelper.toCsv(headers: headers, rows: rows);
      final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sample_import_template.csv');
      await file.writeAsString(csvContent);

      await _scanForCsvFiles();

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sample CSV Generated'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sample import template has been written successfully!'),
                const SizedBox(height: 12),
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
          SnackBar(content: Text('Failed to generate template: $e')),
        );
      }
    }
  }

  Future<void> _importCsv() async {
    if (_selectedLine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target Line.')),
      );
      return;
    }
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a CSV file to import.')),
      );
      return;
    }

    setState(() => _isImporting = true);

    try {
      final client = sl<GraphQLClient>();
      final storage = sl<StorageService>();
      final userId = storage.getUserId();
      if (userId == null) throw Exception('User not authenticated');

      // 1. Read and parse file
      final file = File(_selectedFile!.path);
      final csvContent = await file.readAsString();
      final rows = CsvHelper.parseCsv(csvContent);

      if (rows.isEmpty) {
        throw Exception('The selected file contains no readable records.');
      }

      // 2. Fetch or create Area for Line
      // We check if an Area exists. If not, we create one called "Imported Area".
      const String getAreasQuery = '''
        query GetAreas(\$lineId: uuid!) {
          areas(where: {line_id: {_eq: \$lineId}}) {
            id
            name
          }
        }
      ''';
      final areasResult = await client.query(QueryOptions(
        document: gql(getAreasQuery),
        variables: {'lineId': _selectedLine!.id},
        fetchPolicy: FetchPolicy.networkOnly,
      ));
      
      if (areasResult.hasException) {
        throw Exception('Failed to fetch Line areas: ${areasResult.exception.toString()}');
      }

      final List areasList = areasResult.data?['areas'] ?? [];
      String areaId;
      if (areasList.isNotEmpty) {
        areaId = areasList.first['id'].toString();
      } else {
        // Create an Area
        const String insertAreaMutation = '''
          mutation InsertArea(\$name: String!, \$lineId: uuid!) {
            insert_areas_one(object: {name: \$name, line_id: \$lineId}) {
              id
            }
          }
        ''';
        final insertAreaResult = await client.mutate(MutationOptions(
          document: gql(insertAreaMutation),
          variables: {'name': 'Imported Area', 'lineId': _selectedLine!.id},
        ));
        if (insertAreaResult.hasException) {
          throw Exception('Failed to create default imported area: ${insertAreaResult.exception.toString()}');
        }
        areaId = insertAreaResult.data!['insert_areas_one']['id'].toString();
      }

      // 3. Batch import rows
      int importedCount = 0;
      for (final row in rows) {
        final String name = row['CustomerName'] ?? '';
        if (name.isEmpty) continue; // Skip header/invalid rows

        final String phone = row['MobileNumber'] ?? '';
        final double principal = double.tryParse(row['Amount']?.toString() ?? '0') ?? 0.0;
        final double interest = double.tryParse(row['Interest']?.toString() ?? '0') ?? 0.0;
        final double billAmount = double.tryParse(row['BillAmount']?.toString() ?? '0') ?? 0.0;
        final double totalPaid = double.tryParse(row['TotalAmountPaid']?.toString() ?? '0') ?? 0.0;
        final String startDt = row['TransactionStartDt'] ?? DateTime.now().toIso8601String().split('T')[0];
        
        final double totalAmount = principal + interest;
        final double outstanding = totalAmount - totalPaid;

        // A. Insert Customer
        const String insertCustomerMutation = '''
          mutation InsertCustomer(\$name: String!, \$phone: String, \$lineId: uuid!, \$areaId: uuid!, \$userId: uuid!) {
            insert_customers_one(object: {
              name: \$name,
              phone: \$phone,
              line_id: \$lineId,
              area_id: \$areaId,
              user_id: \$userId
            }) {
              id
            }
          }
        ''';

        final custResult = await client.mutate(MutationOptions(
          document: gql(insertCustomerMutation),
          variables: {
            'name': name,
            'phone': phone.isEmpty ? null : phone,
            'lineId': _selectedLine!.id,
            'areaId': areaId,
            'userId': userId,
          },
        ));

        if (custResult.hasException) continue; // Skip failed records
        final customerId = custResult.data!['insert_customers_one']['id'].toString();

        // B. Insert Active Loan
        const String insertLoanMutation = '''
          mutation InsertLoan(\$object: loans_insert_input!) {
            insert_loans_one(object: \$object) {
              id
            }
          }
        ''';

        final loanResult = await client.mutate(MutationOptions(
          document: gql(insertLoanMutation),
          variables: {
            'object': {
              'customer_id': customerId,
              'principal_amount': principal,
              'interest_amount': interest,
              'total_amount': totalAmount,
              'daily_due_amount': billAmount,
              'outstanding_balance': outstanding,
              'start_date': startDt,
              'end_date': startDt, // default
              'status': outstanding <= 0 ? 'paid' : 'active',
              'user_id': userId,
            }
          },
        ));

        if (loanResult.hasException) continue;

        // C. If previous payments exist, insert collection record
        if (totalPaid > 0) {
          const String insertCollectionMutation = '''
            mutation InsertCollection(\$customerId: uuid!, \$amount: numeric!, \$date: timestamp!, \$userId: uuid!) {
              insert_collections_one(object: {
                customer_id: \$customerId,
                amount: \$amount,
                date: \$date,
                status: "paid",
                user_id: \$userId
              }) {
                id
              }
            }
          ''';
          await client.mutate(MutationOptions(
            document: gql(insertCollectionMutation),
            variables: {
              'customerId': customerId,
              'amount': totalPaid,
              'date': startDt,
              'userId': userId,
            },
          ));
        }

        importedCount++;
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Import Successful'),
            content: Text('Successfully imported $importedCount customer loan records!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Line'),
        elevation: 2,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isFetchingLines
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: _showLineDialog,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _isLineOpen ? Colors.blue : Colors.grey.shade300,
                                  width: _isLineOpen ? 1.5 : 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_selectedLine != null)
                                      const Text('Line', style: TextStyle(fontSize: 12, color: Colors.green)),
                                    Text(
                                      _selectedLine?.name ?? 'Select Target Line',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _isLineOpen ? Colors.redAccent : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  _isLineOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                  color: _isLineOpen ? Colors.redAccent : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // File Selector Dropdown
                        const Text('Select CSV Import File', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 8),
                        _csvFiles.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  border: Border.all(color: Colors.orange.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'No CSV files discovered in device Documents folder.\n\nTap "Download Sample CSV" below to generate a template file, or drop your CSV files into the Documents directory.',
                                  style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<FileSystemEntity>(
                                    value: _selectedFile,
                                    isExpanded: true,
                                    items: _csvFiles.map((file) {
                                      final name = file.path.split(Platform.pathSeparator).last;
                                      return DropdownMenuItem(
                                        value: file,
                                        child: Text(name, style: const TextStyle(fontSize: 14)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedFile = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _scanForCsvFiles,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh Folder Scan', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _isImporting
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _selectedFile == null ? null : _importCsv,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('IMPORT CUSTOMERS', style: TextStyle(fontSize: 16)),
                              ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _downloadSampleCsv,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('DOWNLOAD SAMPLE CSV', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: ExpansionTile(
                      title: Text('Help', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      collapsedIconColor: Theme.of(context).colorScheme.onSurface,
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CSV File Format', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 16),
                              const Text('The following columns are required to import line data', style: TextStyle(fontSize: 15)),
                              const SizedBox(height: 16),
                              const Text(
                                'CustomerName\nAmount\nInterest\nBillAmount\nNoOfInstall\nTransactionStartDt\nTotalAmountPaid',
                                style: TextStyle(color: Colors.redAccent, fontSize: 15, height: 1.4),
                              ),
                              const SizedBox(height: 24),
                              const Text('The following columns are optional to import line data', style: TextStyle(fontSize: 15)),
                              const SizedBox(height: 16),
                              const Text(
                                'CustomerCode\nMobileNumber\nAddress\nCustomerOrder',
                                style: TextStyle(color: Colors.green, fontSize: 15, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: ExpansionTile(
                      title: Text('History', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      collapsedIconColor: Theme.of(context).colorScheme.onSurface,
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: const Text('No history available.'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
