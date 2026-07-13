import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vasooldrive/core/services/app_localization.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalization.languageNotifier,
      builder: (context, language, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Settings'.tr()),
          ),
          body: ListView(
            children: [
              _buildListTile(FontAwesomeIcons.circleQuestion, 'Support', onTap: () {
                context.go('/settings/support');
              }),
              _buildListTile(FontAwesomeIcons.key, 'License', onTap: () {
                context.go('/settings/license');
              }),
              const Divider(),
              _buildListTile(FontAwesomeIcons.list, 'Line Type', onTap: () {
                context.go('/settings/line-type');
              }),
              _buildListTile(FontAwesomeIcons.moneyBillWave, 'Line', onTap: () {
                context.go('/settings/line');
              }),
              _buildListTile(FontAwesomeIcons.cloudArrowDown, 'Import Line', onTap: () {
                context.go('/settings/import-line');
              }),
              _buildListTile(FontAwesomeIcons.cloudArrowUp, 'Export Line', onTap: () {
                context.go('/settings/export-line');
              }),
              const Divider(),
              _buildListTile(FontAwesomeIcons.locationCrosshairs, 'Area', onTap: () {
                context.go('/settings/area');
              }),
              const Divider(),
              _buildListTile(FontAwesomeIcons.solidCreditCard, 'Expense Type', onTap: () {
                context.go('/settings/expense-type');
              }),
              _buildListTile(FontAwesomeIcons.briefcase, 'Investment Type', onTap: () {
                context.go('/settings/investment-type');
              }),
              const Divider(),
              _buildListTile(FontAwesomeIcons.borderAll, 'Site', onTap: () {
                context.go('/settings/site');
              }),
              const Divider(),
              _buildListTile(FontAwesomeIcons.gear, 'My Settings', onTap: () {
                context.go('/settings/my-settings');
              }),
              _buildListTile(FontAwesomeIcons.language, 'Language Settings', onTap: () {
                context.go('/settings/language');
              }),
              _buildListTile(FontAwesomeIcons.commentSms, 'SMS Template', onTap: () {
                context.go('/settings/sms-template');
              }),
              const _FingerprintToggleTile(),
              const _SecurityAlertToggleTile(),
              const _NotificationToggleTile(),
              _buildListTile(FontAwesomeIcons.solidBell, 'Test Notification', onTap: () {
                final isEnabled = sl<StorageService>().getBool('notifications_enabled', defaultValue: true);
                if (!isEnabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications are currently disabled. Enable them first!')),
                  );
                  return;
                }
                sl<NotificationService>().showNow(
                  id: 999,
                  title: 'Test Successful! 🎉',
                  body: 'Your local notifications are working perfectly.',
                );
              }),
              _buildListTile(FontAwesomeIcons.lock, 'Change Password', onTap: () {
                context.go('/settings/change-password');
              }),
              const Divider(),
              _buildListTile(FontAwesomeIcons.palette, 'Theme Settings', onTap: () {
                _showThemeDialog(context);
              }),
              const Divider(),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.powerOff, color: Colors.grey, size: 20),
                title: Text('Sign out'.tr(), style: const TextStyle(color: Colors.red)),
                onTap: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(dynamic icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: FaIcon(icon, color: Colors.grey[700], size: 20),
      title: Text(title.tr()),
      onTap: onTap ?? () {},
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themes = ['Blue', 'Green', 'Orange', 'Dark-Blue', 'Dark-Green', 'Dark-Orange'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Theme'.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: themes.map((theme) {
                return ListTile(
                  title: Text(theme.replaceAll('-', ' ')),
                  leading: Icon(
                    theme.contains('Dark') ? Icons.dark_mode : Icons.light_mode,
                    color: _getThemeColor(theme),
                  ),
                  onTap: () {
                    AppTheme.themeNotifier.value = theme;
                    sl<StorageService>().setString('app_theme', theme);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Color _getThemeColor(String theme) {
    if (theme.contains('Orange')) return Colors.orange;
    if (theme.contains('Green')) return Colors.green;
    return Colors.blue;
  }
}

class _FingerprintToggleTile extends StatefulWidget {
  const _FingerprintToggleTile();

  @override
  State<_FingerprintToggleTile> createState() => _FingerprintToggleTileState();
}

class _FingerprintToggleTileState extends State<_FingerprintToggleTile> {
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = sl<StorageService>().getBool('my_settings_fingerprint_enabled', defaultValue: false);
  }

  Future<void> _toggleFingerprint(bool value) async {
    final storage = sl<StorageService>();
    
    if (value) {
      // Trying to enable
      final localAuth = LocalAuthentication();
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();

      if (canCheckBiometrics || isDeviceSupported) {
        bool biometricSuccess = false;
        try {
          biometricSuccess = await localAuth.authenticate(
            localizedReason: 'Scan your fingerprint or face to enable biometric login',
            biometricOnly: true,
          );
        } catch (e) {
          biometricSuccess = false;
        }

        if (biometricSuccess) {
          await storage.setBool('my_settings_fingerprint_enabled', true);
          setState(() {
            _isEnabled = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometric login enabled successfully!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometric authentication failed or cancelled.')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device does not support biometrics.')),
          );
        }
      }
    } else {
      // Disabling does not require fingerprint confirmation
      await storage.setBool('my_settings_fingerprint_enabled', false);
      setState(() {
        _isEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric login disabled successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: FaIcon(FontAwesomeIcons.fingerprint, color: Colors.grey[700], size: 20),
      title: Text('Enable Biometric Login'.tr()),
      value: _isEnabled,
      onChanged: _toggleFingerprint,
    );
  }
}

class _SecurityAlertToggleTile extends StatefulWidget {
  const _SecurityAlertToggleTile();

  @override
  State<_SecurityAlertToggleTile> createState() => _SecurityAlertToggleTileState();
}

class _SecurityAlertToggleTileState extends State<_SecurityAlertToggleTile> {
  bool _isEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = sl<StorageService>().getBool('my_settings_security_alert_enabled', defaultValue: false);
  }

  Future<void> _toggleSecurityAlert(bool newValue) async {
    final storage = sl<StorageService>();
    await storage.setBool('my_settings_security_alert_enabled', newValue);
    
    setState(() {
      _isEnabled = newValue;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Security OTP Alert ${newValue ? "enabled" : "disabled"} successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: FaIcon(FontAwesomeIcons.shieldHalved, color: Colors.grey[700], size: 20),
      title: Text('Enable Security Alert'.tr()),
      value: _isEnabled,
      onChanged: _toggleSecurityAlert,
    );
  }
}

class _NotificationToggleTile extends StatefulWidget {
  const _NotificationToggleTile();

  @override
  State<_NotificationToggleTile> createState() => _NotificationToggleTileState();
}

class _NotificationToggleTileState extends State<_NotificationToggleTile> {
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = sl<StorageService>().getBool('notifications_enabled', defaultValue: true);
  }

  Future<void> _toggleNotifications(bool newValue) async {
    final storage = sl<StorageService>();
    final notificationService = sl<NotificationService>();

    if (newValue) {
      // Safely request permissions when the user explicitly enables them in Settings
      await notificationService.requestPermissions();
    }

    await storage.setBool('notifications_enabled', newValue);

    if (!newValue) {
      // Cancel all pending notifications when disabled
      try {
        await notificationService.cancelAll();
      } catch (e) {
        print('Error canceling notifications: $e');
      }
    }

    setState(() {
      _isEnabled = newValue;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifications ${newValue ? "enabled" : "disabled"} successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: FaIcon(FontAwesomeIcons.bell, color: Colors.grey[700], size: 20),
      title: Text('Enable Notifications'.tr()),
      value: _isEnabled,
      onChanged: _toggleNotifications,
    );
  }
}

