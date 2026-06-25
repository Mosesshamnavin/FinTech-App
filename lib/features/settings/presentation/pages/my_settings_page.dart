import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MySettingsPage extends StatefulWidget {
  const MySettingsPage({super.key});

  @override
  State<MySettingsPage> createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  // Settings
  bool showTotalInvestment = true;
  bool showAmountInVasool = true;
  bool showArrearAmount = false;
  bool sendSms = false;
  bool smsBalanceInfo = false;
  String orderBy = 'Customer Order';
  bool printer = false;

  // Other Settings
  String scrollSetting = 'Load 50 Customer';
  String swipeSetting = 'Half Swipe Paid';
  String closedLoanDeleteSetting = 'NEVER';
  bool showNewAfterClose = true;
  bool showCallButton = true;
  bool showDecimalNumbers = false;

  // Profile Settings
  String stateValue = 'Test State';
  String primarySite = 'Test Site';

  // Theme
  String selectedTheme = AppTheme.themeNotifier.value;

  // Local Setting
  bool showLineChangeWarning = false;
  bool useNativeCallNumber = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Settings'),
        elevation: 2,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          _buildSettingsSection(),
          _buildOtherSettingsSection(),
          _buildProfileSettingsSection(),
          _buildLocalSettingSection(),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return ExpansionTile(
      title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      children: [
        Container(
          child: Column(
            children: [
              SwitchListTile(title: const Text('Show Total Investment In Vasool'), value: showTotalInvestment, onChanged: (v) => setState(() => showTotalInvestment = v)),
              SwitchListTile(title: const Text('Show Amount in Vasool'), value: showAmountInVasool, onChanged: (v) => setState(() => showAmountInVasool = v)),
              SwitchListTile(title: const Text('Show Arrear Amount'), value: showArrearAmount, onChanged: (v) => setState(() => showArrearAmount = v)),
              SwitchListTile(title: const Text('Send SMS'), value: sendSms, onChanged: (v) => setState(() => sendSms = v)),
              SwitchListTile(title: const Text('SMS Balance Info to Customer?'), value: smsBalanceInfo, onChanged: (v) => setState(() => smsBalanceInfo = v)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Order By', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)),
                  value: orderBy,
                  items: ['Customer Order', 'Other'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => orderBy = v!),
                ),
              ),
              SwitchListTile(title: const Text('Printer'), value: printer, onChanged: (v) => setState(() => printer = v)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () {}, child: const Text('SUBMIT')),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherSettingsSection() {
    return ExpansionTile(
      title: const Text('Other Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      children: [
        Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'SCROLL SETTING', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)),
                  value: scrollSetting,
                  items: ['Load 50 Customer'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => scrollSetting = v!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'SWIPE SETTING', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)),
                  value: swipeSetting,
                  items: ['Half Swipe Paid'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => swipeSetting = v!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  decoration: const InputDecoration(labelText: 'AMOUNT SETTING', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)),
                  controller: TextEditingController(text: '100,200,500,625,1000,1200,1250,1500,2000'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'CLOSED LOAN DELETE SETTING', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)),
                  value: closedLoanDeleteSetting,
                  items: ['NEVER'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => closedLoanDeleteSetting = v!),
                ),
              ),
              SwitchListTile(title: const Text('SHOW NEW AFTER CLOSE LOAN', style: TextStyle(fontSize: 14)), value: showNewAfterClose, onChanged: (v) => setState(() => showNewAfterClose = v)),
              SwitchListTile(title: const Text('SHOW CALL BUTTON IN COLLECTION', style: TextStyle(fontSize: 14)), value: showCallButton, onChanged: (v) => setState(() => showCallButton = v)),
              SwitchListTile(title: const Text('SHOW DECIMAL NUMBERS', style: TextStyle(fontSize: 14)), value: showDecimalNumbers, onChanged: (v) => setState(() => showDecimalNumbers = v)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () {}, child: const Text('SUBMIT')),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSettingsSection() {
    return ExpansionTile(
      title: const Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      children: [
        Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(decoration: const InputDecoration(labelText: 'Name', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)), controller: TextEditingController(text: 'Test User')),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(decoration: const InputDecoration(labelText: 'Mobile Number', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)), controller: TextEditingController(text: '1234567890')),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(decoration: const InputDecoration(labelText: 'Email ID', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)), controller: TextEditingController(text: 'test@example.com')),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'State', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)),
                  value: stateValue,
                  items: ['Test State', 'Other State', if (!['Test State', 'Other State'].contains(stateValue)) stateValue].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => stateValue = v!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Primary Site', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)),
                  value: primarySite,
                  items: ['Test Site', 'Other Site', if (!['Test Site', 'Other Site'].contains(primarySite)) primarySite].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => primarySite = v!),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () {}, child: const Text('SUBMIT')),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Color _getThemeColor(String themeName) {
    if (themeName.contains('Orange')) return Colors.orange;
    if (themeName.contains('Green')) return Colors.green;
    return Colors.blue;
  }



  Widget _buildLocalSettingSection() {
    return ExpansionTile(
      title: const Text('Local Setting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      children: [
        Container(
          child: Column(
            children: [
              ListTile(
                title: const Text('Show Line Change Warning', style: TextStyle(fontSize: 14)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(value: showLineChangeWarning, onChanged: (v) => setState(() => showLineChangeWarning = v)),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () {}, child: const Text('SAVE')),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Use Native Call Number', style: TextStyle(fontSize: 14)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(value: useNativeCallNumber, onChanged: (v) => setState(() => useNativeCallNumber = v)),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () {}, child: const Text('SAVE')),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Line', style: TextStyle(fontSize: 14)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: null,
                      underline: const SizedBox(),
                      hint: const SizedBox(width: 20),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      items: const [],
                      onChanged: (v) {},
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () {}, child: const Text('CLEAR CACHE')),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
