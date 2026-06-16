import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            tabs: [
              Tab(text: 'SEND OTP'),
              Tab(text: 'RESET PASSWORD'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSendOtpView(),
            _buildResetPasswordView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSendOtpView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'OTP will be sent to your registered email address. You can reset password using the OTP.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            child: const Text('SEND OTP'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(labelText: 'OTP'),
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
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }
}
