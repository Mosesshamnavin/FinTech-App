import 'package:flutter/material.dart';

class EnableFingerprintPage extends StatefulWidget {
  const EnableFingerprintPage({super.key});

  @override
  State<EnableFingerprintPage> createState() => _EnableFingerprintPageState();
}

class _EnableFingerprintPageState extends State<EnableFingerprintPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enable Fingerprint'),
        elevation: 2,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.3),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Submit logic
              },
              child: const Text('SUBMIT'),
            ),
          ),
        ],
      ),
    );
  }
}
