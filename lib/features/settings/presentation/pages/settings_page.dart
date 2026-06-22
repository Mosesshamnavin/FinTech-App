import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
          _buildListTile(FontAwesomeIcons.fingerprint, 'Enable Fingerprint', onTap: () {
            context.go('/settings/enable-fingerprint');
          }),
          _buildListTile(FontAwesomeIcons.shieldHalved, 'Enable Security Alert', onTap: () {
            context.go('/settings/enable-security-alert');
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
            title: const Text('Sign out', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(dynamic icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: FaIcon(icon, color: Colors.grey[700], size: 20),
      title: Text(title),
      onTap: onTap ?? () {},
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themes = ['Blue', 'Green', 'Orange', 'Dark-Blue', 'Dark-Green', 'Dark-Orange'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
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
