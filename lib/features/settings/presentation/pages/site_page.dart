import 'package:flutter/material.dart';

class SitePage extends StatelessWidget {
  const SitePage({super.key});

  @override
  Widget build(BuildContext context) {
    // This should ideally be fetched from the authentication state
    final String loggedInUser = 'Demo user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Site'),
        elevation: 2,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(loggedInUser),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          const Divider(height: 1, thickness: 0.3),
        ],
      ),
    );
  }
}
