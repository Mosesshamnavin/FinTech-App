import 'package:flutter/material.dart';

class AddAreaPage extends StatefulWidget {
  const AddAreaPage({super.key});

  @override
  State<AddAreaPage> createState() => _AddAreaPageState();
}

class _AddAreaPageState extends State<AddAreaPage> {
  bool _isDropdownOpen = false;

  void _showLineDialog() async {
    setState(() {
      _isDropdownOpen = true;
    });
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Line'),
          contentPadding: const EdgeInsets.only(top: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              // List of lines would go here, empty for now as per screenshot
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Area'),
        elevation: 2,
        shadowColor: Colors.black26,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'AreaName',
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _showLineDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_isDropdownOpen)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Line', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                          const SizedBox(height: 4),
                          const Text('Line', style: TextStyle(fontSize: 16, color: Colors.red)),
                        ],
                      )
                    else
                      const Text('Line', style: TextStyle(fontSize: 16, color: Colors.black87)),
                    Icon(
                      _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: _isDropdownOpen ? Colors.red : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Save logic
                },
                child: const Text('SAVE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
