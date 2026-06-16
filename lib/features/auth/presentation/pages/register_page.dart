import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Icon(Icons.receipt_long, size: 60, color: Colors.orange),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'VASOOL DRIVE',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'User Name'),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password'),
            ),
            const SizedBox(height: 16),
            const TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email ID'),
            ),
            const SizedBox(height: 16),
            const TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Mobile'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'State'),
              value: 'Tamil Nadu',
              items: ['Tamil Nadu'].map((state) {
                return DropdownMenuItem(value: state, child: Text(state));
              }).toList(),
              onChanged: (val) {},
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('NEXT'),
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                children: [
                  const TextSpan(text: 'By registering and logging in, you agree to our '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(color: Colors.lightBlue[400]),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(color: Colors.lightBlue[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
