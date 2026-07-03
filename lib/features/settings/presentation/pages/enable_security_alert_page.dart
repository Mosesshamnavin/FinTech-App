import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';

class EnableSecurityAlertPage extends StatefulWidget {
  const EnableSecurityAlertPage({super.key});

  @override
  State<EnableSecurityAlertPage> createState() => _EnableSecurityAlertPageState();
}

class _EnableSecurityAlertPageState extends State<EnableSecurityAlertPage> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _currentlyEnabled = false;

  @override
  void initState() {
    super.initState();
    _currentlyEnabled = sl<StorageService>().getBool('my_settings_security_alert_enabled', defaultValue: false);
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
        await storage.setBool('my_settings_security_alert_enabled', newStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Security OTP Alert ${newStatus ? "enabled" : "disabled"} successfully!')),
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
        title: const Text('Enable Security Alert'),
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
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'When a new login attempt is made in new device, OTP will be sent to registered email address',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _currentlyEnabled
                    ? 'Security OTP Alert is currently ENABLED.\nEnter password to disable it.'
                    : 'Enter password to enable Security OTP Alert.',
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
