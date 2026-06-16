import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

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
          /*
          _buildListTile(FontAwesomeIcons.circleQuestion, 'Support'),
          _buildListTile(FontAwesomeIcons.key, 'License'),
          const Divider(),
          _buildListTile(FontAwesomeIcons.moneyBillWave, 'Line'),
          _buildListTile(FontAwesomeIcons.cloudArrowDown, 'Import Line'),
          _buildListTile(FontAwesomeIcons.cloudArrowUp, 'Export Line'),
          const Divider(),
          _buildListTile(FontAwesomeIcons.locationCrosshairs, 'Area'),
          const Divider(),
          _buildListTile(FontAwesomeIcons.solidCreditCard, 'Expense Type'),
          _buildListTile(FontAwesomeIcons.briefcase, 'Investment Type'),
          const Divider(),
          _buildListTile(FontAwesomeIcons.borderAll, 'Site'),
          const Divider(),
          */
          _buildListTile(FontAwesomeIcons.gear, 'My Settings', onTap: () {
            context.go('/settings/my-settings');
          }),
          _buildListTile(FontAwesomeIcons.language, 'Language Settings', onTap: () {
            context.go('/settings/language');
          }),
          /*
          _buildListTile(FontAwesomeIcons.commentSms, 'SMS Template'),
          _buildListTile(FontAwesomeIcons.fingerprint, 'Enable Fingerprint'),
          _buildListTile(FontAwesomeIcons.shieldHalved, 'Enable Security Alert'),
          _buildListTile(FontAwesomeIcons.lock, 'Change Password'),
          const Divider(),
          */
          const Divider(),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.powerOff, color: Colors.grey, size: 20),
            title: const Text('Sign out', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.go('/login');
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
}
