import 'package:url_launcher/url_launcher.dart';
import 'storage_service.dart';
import '../../features/loans/data/datasources/loan_remote_datasource.dart';
import '../../features/loans/domain/entities/loan_entity.dart';
import 'dart:convert';

class SmsService {
  final StorageService _storageService;
  final LoanRemoteDataSource _loanRemoteDataSource;

  SmsService({
    required StorageService storageService,
    required LoanRemoteDataSource loanRemoteDataSource,
  })  : _storageService = storageService,
        _loanRemoteDataSource = loanRemoteDataSource;

  /// Helper to clean/format phone numbers (e.g. prefix 91 if it's a 10 digit number)
  String formatPhoneNumber(String phone) {
    final clean = phone.replaceAll(RegExp(r'\s+|-|\(|\)'), '');
    if (clean.length == 10) {
      return '91$clean';
    }
    return clean;
  }

  /// Composes the template text, loading saved preferences from StorageService.
  /// If no template is saved, falls back to default templates.
  Future<String> composeMessage({
    required String flow, // 'Collection', 'Loan Payment', 'Loan Detail'
    required String language, // 'en' or 'ta'
    required String customerName,
    required double amountPaidToday,
    required String date,
    String? customerId,
  }) async {
    final key = 'sms_template_$flow';
    final savedJson = _storageService.getString(key);
    List<dynamic> rows = [];
    if (savedJson.isNotEmpty) {
      try {
        rows = json.decode(savedJson);
      } catch (_) {}
    }

    if (rows.isEmpty) {
      if (flow == 'Collection') {
        rows = [
          {'en': '{CustomerName}', 'ta': '{CustomerName}'},
          {'en': 'Today: {AmountPaidToday}', 'ta': 'இன்று: {AmountPaidToday}'},
          {'en': 'Total: {TotalAmount}', 'ta': 'மொத்தம்: {TotalAmount}'},
          {'en': 'Start Date: {TransactionStartDt}', 'ta': 'தேதி: {TransactionStartDt}'},
          {'en': 'Thank you', 'ta': 'நன்றி'},
          {'en': '{FinanceName}', 'ta': '{FinanceName}'},
        ];
      } else if (flow == 'Loan Payment') {
        rows = [
          {'en': '{CustomerName}', 'ta': '{CustomerName}'},
          {'en': 'Product: {ProductName}', 'ta': 'பொருள்: {ProductName}'},
          {'en': 'Amount: {Amount}', 'ta': 'அசல்: {Amount}'},
          {'en': 'Interest: {Interest}', 'ta': 'வட்டி: {Interest}'},
          {'en': 'Total: {TotalAmount}', 'ta': 'மொத்தம்: {TotalAmount}'},
          {'en': '{FinanceName}', 'ta': '{FinanceName}'},
        ];
      } else if (flow == 'Loan Detail') {
        rows = [
          {'en': '{CustomerName}', 'ta': '{CustomerName}'},
          {'en': 'Product: {ProductName}', 'ta': 'பொருள்: {ProductName}'},
          {'en': 'Amount: {Amount}', 'ta': 'அசல்: {Amount}'},
          {'en': 'Interest: {Interest}', 'ta': 'வட்டி: {Interest}'},
          {'en': 'Total: {TotalAmount}', 'ta': 'மொத்தம்: {TotalAmount}'},
          {'en': 'Start Date: {TransactionStartDt}', 'ta': 'தேதி: {TransactionStartDt}'},
          {'en': '{TransactionHistory}', 'ta': '{TransactionHistory}'},
          {'en': 'Thank you', 'ta': 'நன்றி'},
          {'en': '{FinanceName}', 'ta': '{FinanceName}'},
        ];
      }
    }

    LoanEntity? activeLoan;
    if (customerId != null) {
      try {
        final loans = await _loanRemoteDataSource.getLoansByCustomer(customerId);
        activeLoan = loans.firstWhere((l) => l.status == 'Active', orElse: () => loans.first);
      } catch (_) {}
    }

    final totalAmount = activeLoan?.totalAmount.toStringAsFixed(0) ?? '0';
    final startDate = activeLoan != null
        ? '${activeLoan.startDate.day.toString().padLeft(2, '0')}/${activeLoan.startDate.month.toString().padLeft(2, '0')}/${activeLoan.startDate.year}'
        : date;
    final productName = 'Loan';
    final principal = activeLoan?.principalAmount.toStringAsFixed(0) ?? '0';
    final interest = activeLoan?.interestAmount.toStringAsFixed(0) ?? '0';
    final financeName = _storageService.getString('finance_name', defaultValue: 'Vasool Drive');

    final composedLines = <String>[];
    for (var r in rows) {
      final lineTemplate = r[language]?.toString() ?? '';
      final formattedLine = lineTemplate
          .replaceAll('{CustomerName}', customerName)
          .replaceAll('{AmountPaidToday}', amountPaidToday.toStringAsFixed(0))
          .replaceAll('{TotalAmount}', totalAmount)
          .replaceAll('{TransactionStartDt}', startDate)
          .replaceAll('{FinanceName}', financeName)
          .replaceAll('{ProductName}', productName)
          .replaceAll('{Amount}', principal)
          .replaceAll('{Interest}', interest)
          .replaceAll('{TransactionHistory}', '');
      composedLines.add(formattedLine);
    }

    return composedLines.join('\n');
  }

  /// Sends the formatted message via WhatsApp
  Future<bool> sendWhatsApp({
    required String phone,
    required String text,
  }) async {
    final cleanPhone = formatPhoneNumber(phone);
    final url = 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(text)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Sends the formatted message via SMS
  Future<bool> sendSMS({
    required String phone,
    required String text,
  }) async {
    final cleanPhone = formatPhoneNumber(phone);
    final url = 'sms:$cleanPhone?body=${Uri.encodeComponent(text)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}
