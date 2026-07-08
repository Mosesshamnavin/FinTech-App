import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/storage_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Navigate based on Auth State after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          
          // Check if biometrics is enabled
          final storage = di.sl<StorageService>();
          final isFingerprintEnabled = storage.getBool('my_settings_fingerprint_enabled', defaultValue: false);
          
          if (isFingerprintEnabled) {
            final localAuth = LocalAuthentication();
            bool didAuthenticate = false;
            
            try {
              didAuthenticate = await localAuth.authenticate(
                localizedReason: 'Scan your fingerprint or face to unlock Vasool Drive',
                biometricOnly: true,
              );
            } catch (e) {
              didAuthenticate = false;
            }
            
            if (mounted) {
              if (didAuthenticate) {
                context.go('/collections');
              } else {
                // Biometrics failed or cancelled, log the user out so they can log in via password
                context.read<AuthBloc>().add(const AuthLogoutRequested());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Biometric authentication failed or cancelled.')),
                );
              }
            }
          } else {
            context.go('/collections');
          }
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100), // Perfect circle for a 200x200 image
                child: const Image(
                  image: AssetImage('assets/images/logo.jpeg'),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SRI VINAYAGA FINANCE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
