import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';

class SitePage extends StatelessWidget {
  const SitePage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String loggedInUser = 'Unknown User';
          if (state is AuthAuthenticated) {
            loggedInUser = state.user.username;
          }
          return ListView(
            children: [
              ListTile(
                title: Text(loggedInUser),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              const Divider(height: 1, thickness: 0.3),
            ],
          );
        },
      ),
    );
  }
}
