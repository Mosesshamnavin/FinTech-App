import 'package:flutter/material.dart';

class ImportLinePage extends StatefulWidget {
  const ImportLinePage({super.key});

  @override
  State<ImportLinePage> createState() => _ImportLinePageState();
}

class _ImportLinePageState extends State<ImportLinePage> {
  bool _isLineOpen = false;

  void _showLineDialog() async {
    setState(() {
      _isLineOpen = true;
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Line', style: TextStyle(fontWeight: FontWeight.normal)),
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

    if (mounted) {
      setState(() {
        _isLineOpen = false;
      });
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
      body: SingleChildScrollView(
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
                          bottom: BorderSide(color: _isLineOpen ? Colors.blue : Colors.grey.shade300, width: _isLineOpen ? 1.5 : 1.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Line', style: TextStyle(fontSize: 16, color: _isLineOpen ? Colors.redAccent : Colors.black87)),
                          Icon(
                            _isLineOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            color: _isLineOpen ? Colors.redAccent : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text('Choose file', style: TextStyle(color: Colors.black87)),
                      ),
                      const SizedBox(width: 8),
                      const Text('No file chosen', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade200,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('IMPORT', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade600,
                      foregroundColor: Colors.white,
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
              color: Colors.grey.shade50,
              child: ExpansionTile(
                title: const Text('Help', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                iconColor: Colors.black,
                collapsedIconColor: Colors.black,
                children: [
                  Container(
                    color: Colors.white,
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
              color: Colors.grey.shade50,
              child: ExpansionTile(
                title: const Text('History', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                iconColor: Colors.black,
                collapsedIconColor: Colors.black,
                children: [
                  Container(
                    color: Colors.white,
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
