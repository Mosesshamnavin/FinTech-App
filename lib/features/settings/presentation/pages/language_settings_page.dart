import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';
import 'package:vasooldrive/core/services/app_localization.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  final StorageService _storageService = sl<StorageService>();
  String selectedLanguage = 'English'; // App Language
  
  // English SMS
  final Map<String, String> _englishSms = {
    'Amount': 'Total',
    'AmountPaidToday': 'Today',
    'NextDue': 'Next Due',
    'Product': 'Product',
    'StartDate': 'Start Date',
    'TotalAmountDue': 'Pending',
    'TotalAmountPaid': 'Paid',
  };

  // Hindi SMS
  final Map<String, String> _hindiSms = {
    'Amount': 'राशि',
    'AmountPaidToday': 'आज',
    'NextDue': 'अगला बकाया',
    'Product': 'Product',
    'StartDate': 'आरंभ करने की तिथि',
    'TotalAmountDue': 'देय',
    'TotalAmountPaid': 'भुगतान किया',
  };

  // Tamil SMS
  final Map<String, String> _tamilSms = {
    'Amount': 'மொத்தம்',
    'AmountPaidToday': 'இன்றைய வரவு',
    'NextDue': 'அடுத்த தவணை',
    'Product': 'பொருள்',
    'StartDate': 'துவக்க தேதி',
    'TotalAmountDue': 'பாக்கி',
    'TotalAmountPaid': 'வரவு',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    selectedLanguage = _storageService.getString('app_language', defaultValue: 'English');
    
    // Load English custom labels
    for (final key in _englishSms.keys) {
      final val = _storageService.getString('sms_label_en_$key');
      if (val.isNotEmpty) {
        _englishSms[key] = val;
      }
    }
    
    // Load Hindi custom labels
    for (final key in _hindiSms.keys) {
      final val = _storageService.getString('sms_label_hi_$key');
      if (val.isNotEmpty) {
        _hindiSms[key] = val;
      }
    }
    
    // Load Tamil custom labels
    for (final key in _tamilSms.keys) {
      final val = _storageService.getString('sms_label_ta_$key');
      if (val.isNotEmpty) {
        _tamilSms[key] = val;
      }
    }
    
    setState(() {});
  }

  Widget _buildLanguageAccordion() {
    return ExpansionTile(
      title: const Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
      initiallyExpanded: true,
      children: [
        RadioListTile<String>(
          title: const Text('English'),
          value: 'English',
          groupValue: selectedLanguage,
          onChanged: (v) => setState(() => selectedLanguage = v!),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        RadioListTile<String>(
          title: const Text('தமிழ்'),
          value: 'தமிழ்',
          groupValue: selectedLanguage,
          onChanged: (v) => setState(() => selectedLanguage = v!),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        RadioListTile<String>(
          title: const Text('हिंदी'),
          value: 'हिंदी',
          groupValue: selectedLanguage,
          onChanged: (v) => setState(() => selectedLanguage = v!),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            await _storageService.setString('app_language', selectedLanguage);
            AppLocalization.languageNotifier.value = selectedLanguage;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language saved!'), behavior: SnackBarBehavior.floating),
              );
            }
          },
          child: const Text('SUBMIT'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSmsLanguageAccordion() {
    return ExpansionTile(
      title: const Text('SMS Language', style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        _buildSmsSection('English', _englishSms),
        _buildSmsSection('Hindi', _hindiSms),
        _buildSmsSection('Tamil', _tamilSms),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            // Save English
            for (var entry in _englishSms.entries) {
              await _storageService.setString('sms_label_en_${entry.key}', entry.value);
            }
            // Save Hindi
            for (var entry in _hindiSms.entries) {
              await _storageService.setString('sms_label_hi_${entry.key}', entry.value);
            }
            // Save Tamil
            for (var entry in _tamilSms.entries) {
              await _storageService.setString('sms_label_ta_${entry.key}', entry.value);
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SMS Language settings saved!'), behavior: SnackBarBehavior.floating),
              );
            }
          },
          child: const Text('SUBMIT'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSmsSection(String language, Map<String, String> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            language,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...fields.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: TextFormField(
              key: ValueKey('${language}_${entry.key}_${entry.value}'),
              initialValue: entry.value,
              decoration: InputDecoration(
                labelText: entry.key,
                labelStyle: const TextStyle(fontSize: 14),
                border: const UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              onChanged: (v) {
                fields[entry.key] = v;
              },
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildLanguageAccordion(),
            const Divider(height: 1),
            _buildSmsLanguageAccordion(),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
