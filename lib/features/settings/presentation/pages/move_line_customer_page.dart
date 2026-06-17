import 'package:flutter/material.dart';

class MoveLineCustomerPage extends StatelessWidget {
  const MoveLineCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Move Line/Customer'),
          elevation: 2,
          shadowColor: Colors.black26,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            tabs: [
              Tab(text: 'CUSTOMER'),
              Tab(text: 'LINE'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // CUSTOMER Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _MoveDropdown(label: 'Line'),
                  const SizedBox(height: 8),
                  const _MoveDropdown(label: 'Target Line'),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _MoveDropdown(label: 'Area'),
                ],
              ),
            ),
            
            // LINE Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _MoveDropdown(label: 'Target Site'),
                  const SizedBox(height: 8),
                  const _MoveDropdown(label: 'Line'),
                  const SizedBox(height: 8),
                  const _MoveDropdown(label: 'Confirm Line'),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('MOVE'),
                    ),
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

class _MoveDropdown extends StatefulWidget {
  final String label;

  const _MoveDropdown({required this.label});

  @override
  State<_MoveDropdown> createState() => _MoveDropdownState();
}

class _MoveDropdownState extends State<_MoveDropdown> {
  bool _isOpen = false;

  void _showDropdownDialog() async {
    setState(() {
      _isOpen = true;
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.normal)),
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
        _isOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDropdownDialog,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _isOpen ? Colors.blue : Colors.grey.shade300, width: _isOpen ? 1.5 : 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: TextStyle(fontSize: 16, color: _isOpen ? Colors.redAccent : Colors.black87)),
            Icon(
              _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: _isOpen ? Colors.redAccent : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
