import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart' as graphql;

class MySettingsPage extends StatefulWidget {
  const MySettingsPage({super.key});

  @override
  State<MySettingsPage> createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  late final StorageService _storage;

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
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  String stateValue = 'Test State';
  String primarySite = 'Test Site';

  // Theme
  String selectedTheme = AppTheme.themeNotifier.value;

  // Local Setting
  bool showLineChangeWarning = false;
  bool useNativeCallNumber = false;

  @override
  void initState() {
    super.initState();
    _storage = sl<StorageService>();

    // Load Settings
    showTotalInvestment = _storage.getBool('my_settings_show_total_investment', defaultValue: true);
    showAmountInVasool = _storage.getBool('my_settings_show_amount_in_vasool', defaultValue: true);
    showArrearAmount = _storage.getBool('my_settings_show_arrear_amount', defaultValue: false);
    sendSms = _storage.getBool('my_settings_send_sms', defaultValue: false);
    smsBalanceInfo = _storage.getBool('my_settings_sms_balance_info', defaultValue: false);
    orderBy = _storage.getString('my_settings_order_by', defaultValue: 'Customer Order');
    printer = _storage.getBool('my_settings_printer', defaultValue: false);

    // Load Other Settings
    scrollSetting = _storage.getString('my_settings_scroll_setting', defaultValue: 'Load 50 Customer');
    swipeSetting = _storage.getString('my_settings_swipe_setting', defaultValue: 'Half Swipe Paid');
    closedLoanDeleteSetting = _storage.getString('my_settings_closed_loan_delete_setting', defaultValue: 'NEVER');
    showNewAfterClose = _storage.getBool('my_settings_show_new_after_close', defaultValue: true);
    showCallButton = _storage.getBool('my_settings_show_call_button', defaultValue: true);
    showDecimalNumbers = _storage.getBool('my_settings_show_decimal_numbers', defaultValue: false);

    // Load Profile Settings
    _nameController = TextEditingController(text: _storage.getName() ?? 'Test User');
    _mobileController = TextEditingController(text: _storage.getMobile() ?? '');
    _emailController = TextEditingController(text: _storage.getEmail() ?? '');
    stateValue = _storage.getString('my_settings_state', defaultValue: 'Test State');
    primarySite = _storage.getString('my_settings_primary_site', defaultValue: 'Test Site');

    // Load Local Settings
    showLineChangeWarning = _storage.getBool('local_settings_show_line_change_warning', defaultValue: false);
    useNativeCallNumber = _storage.getBool('local_settings_use_native_call_number', defaultValue: false);
    
    _fetchProfileFromDb();
  }

  Future<void> _fetchProfileFromDb() async {
    try {
      final userId = _storage.getUserId();
      if (userId == null) return;
      final client = sl<graphql.GraphQLClient>();
      final result = await client.query(graphql.QueryOptions(
        document: graphql.gql(r'''
          query GetUser($id: uuid!) {
            users_by_pk(id: $id) {
              email
              mobile
            }
          }
        '''),
        variables: {'id': userId},
        fetchPolicy: graphql.FetchPolicy.networkOnly,
      ));
      if (result.data != null && result.data!['users_by_pk'] != null) {
        final email = result.data!['users_by_pk']['email']?.toString() ?? '';
        final mobile = result.data!['users_by_pk']['mobile']?.toString() ?? '';
        if (mounted) {
          setState(() {
            _emailController.text = email;
            _mobileController.text = mobile;
          });
        }
        await _storage.saveEmail(email);
        await _storage.saveMobile(mobile);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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
              ElevatedButton(
                onPressed: () async {
                  await _storage.setBool('my_settings_show_total_investment', showTotalInvestment);
                  await _storage.setBool('my_settings_show_amount_in_vasool', showAmountInVasool);
                  await _storage.setBool('my_settings_show_arrear_amount', showArrearAmount);
                  await _storage.setBool('my_settings_send_sms', sendSms);
                  await _storage.setBool('my_settings_sms_balance_info', smsBalanceInfo);
                  await _storage.setString('my_settings_order_by', orderBy);
                  await _storage.setBool('my_settings_printer', printer);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings saved successfully!')),
                    );
                  }
                },
                child: const Text('SUBMIT'),
              ),
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
              ElevatedButton(
                onPressed: () async {
                  await _storage.setString('my_settings_scroll_setting', scrollSetting);
                  await _storage.setString('my_settings_swipe_setting', swipeSetting);
                  await _storage.setString('my_settings_closed_loan_delete_setting', closedLoanDeleteSetting);
                  await _storage.setBool('my_settings_show_new_after_close', showNewAfterClose);
                  await _storage.setBool('my_settings_show_call_button', showCallButton);
                  await _storage.setBool('my_settings_show_decimal_numbers', showDecimalNumbers);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Other settings saved successfully!')),
                    );
                  }
                },
                child: const Text('SUBMIT'),
              ),
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
                child: TextField(decoration: const InputDecoration(labelText: 'Name', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)), controller: _nameController),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(decoration: const InputDecoration(labelText: 'Mobile Number', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)), controller: _mobileController),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(decoration: const InputDecoration(labelText: 'Email ID', border: InputBorder.none, labelStyle: TextStyle(fontSize: 14)), controller: _emailController),
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
              ElevatedButton(
                onPressed: () async {
                  await _storage.saveName(_nameController.text);
                  await _storage.setString('my_settings_profile_phone', _mobileController.text);
                  await _storage.setString('my_settings_profile_email', _emailController.text);
                  await _storage.setString('my_settings_state', stateValue);
                  await _storage.setString('my_settings_primary_site', primarySite);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile settings saved successfully!')),
                    );
                  }
                },
                child: const Text('SUBMIT'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
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
                    ElevatedButton(
                      onPressed: () async {
                        await _storage.setBool('local_settings_show_line_change_warning', showLineChangeWarning);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Warning settings saved!')),
                          );
                        }
                      },
                      child: const Text('SAVE'),
                    ),
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
                    ElevatedButton(
                      onPressed: () async {
                        await _storage.setBool('local_settings_use_native_call_number', useNativeCallNumber);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Native call settings saved!')),
                          );
                        }
                      },
                      child: const Text('SAVE'),
                    ),
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
                    ElevatedButton(
                      onPressed: () {
                        // Clear cache logic placeholder
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cache cleared!')),
                        );
                      },
                      child: const Text('CLEAR CACHE'),
                    ),
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
