import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';

class EnableFingerprintPage extends StatefulWidget {
  const EnableFingerprintPage({super.key});

  @override
  State<EnableFingerprintPage> createState() => _EnableFingerprintPageState();
}

class _EnableFingerprintPageState extends State<EnableFingerprintPage> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _currentlyEnabled = false;

  @override
  void initState() {
    super.initState();
    _currentlyEnabled = sl<StorageService>().getBool('my_settings_fingerprint_enabled', defaultValue: false);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter password.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storage = sl<StorageService>();
      final userId = storage.getUserId();
      if (userId == null) throw Exception('User not authenticated');

      final client = sl<GraphQLClient>();
      const String query = '''
        query ValidatePassword(\$userId: uuid!, \$password: String!) {
          users(where: {id: {_eq: \$userId}, password: {_eq: \$password}}) {
            id
          }
        }
      ''';

      final result = await client.query(QueryOptions(
        document: gql(query),
        variables: {
          'userId': userId,
          'password': password,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List users = result.data?['users'] ?? [];
      if (users.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password.')),
          );
        }
      } else {
        final newStatus = !_currentlyEnabled;
        await storage.setBool('my_settings_fingerprint_enabled', newStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fingerprint ${newStatus ? "enabled" : "disabled"} successfully!')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _currentlyEnabled
                    ? 'Fingerprint login is currently ENABLED.\nEnter password to disable it.'
                    : 'Enter password to enable fingerprint login.',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
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
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('SUBMIT'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
