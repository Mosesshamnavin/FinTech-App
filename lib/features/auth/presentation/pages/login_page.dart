import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo Placeholder
              const Center(
                child: Icon(Icons.receipt_long, size: 80, color: Colors.orange),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'VASOOL DRIVE',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'USER NAME',
                  hintText: 'Enter Your User Name',
                ),
              ),
              const SizedBox(height: 24),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    context.push('/forgot-password');
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to home after login
                  context.go('/collections');
                },
                child: const Text('LOGIN'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  context.push('/register');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.lightBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('OPEN AN ACCOUNT', style: TextStyle(color: Colors.lightBlue)),
              ),
              const SizedBox(height: 64),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Support', style: TextStyle(color: Colors.lightBlue, fontSize: 16)),
                ),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: Text('26.6.2', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
