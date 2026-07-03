import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:intl/intl.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/report_entity.dart';
import '../../../../core/services/storage_service.dart';
import 'report_remote_datasource.dart';

class HasuraReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final GraphQLClient client;
  final StorageService storageService;

  HasuraReportRemoteDataSourceImpl({required this.client, required this.storageService});

  String _fmt(double v) => '₹${NumberFormat('#,##,##0').format(v.round())}';
  String _fmtDate(String iso) => DateFormat('dd/MM/yyyy').format(DateTime.parse(iso));
  Map<String, dynamic> _dateRange(String from, String to) {
    final fromP = DateFormat('dd/MM/yyyy').parse(from);
    final toP = DateFormat('dd/MM/yyyy').parse(to);
    return {
      'start': fromP.toIso8601String(),
      'end': DateTime(toP.year, toP.month, toP.day, 23, 59, 59).toIso8601String(),
    };
  }

  // ─── Plan Report ────────────────────────────────────────────────────────────
  @override
  Future<ReportEntity> getPlanReport({String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = <String, dynamic>{};
    String lineFilter = '';
    if (line != null && line != 'All') {
      lineFilter = ', customer: {line_id: {_eq: \$lineId}}';
      vars['lineId'] = line;
    }
    final query = '''
      query GetPlanReport${line != null && line != 'All' ? '(\$lineId: uuid)' : ''} {
        loans(where: {status: {_eq: "Active"}$lineFilter}, order_by: {customer: {name: asc}}) {
          id daily_due_amount outstanding_balance
          customer { name phone line { name } }
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List loansData = result.data?['loans'] ?? [];
    double totalExpected = 0;
    final rows = <Map<String, String>>[];
    for (var l in loansData) {
      final dailyDue = double.tryParse(l['daily_due_amount']?.toString() ?? '0') ?? 0;
      final outstanding = double.tryParse(l['outstanding_balance']?.toString() ?? '0') ?? 0;
      totalExpected += dailyDue;
      rows.add({
        'Customer': l['customer']?['name']?.toString() ?? '',
        'Phone': l['customer']?['phone']?.toString() ?? '',
        'Line': l['customer']?['line']?['name']?.toString() ?? '',
        'Expected Due': _fmt(dailyDue),
        'Outstanding': _fmt(outstanding),
      });
    }
    return ReportEntity(
      title: 'Collection Plan',
      summaryFields: {
        'Total Customers': loansData.length.toString(),
        'Total Expected Due': _fmt(totalExpected),
      },
      columns: ['Customer', 'Phone', 'Line', 'Expected Due', 'Outstanding'],
      rows: rows,
    );
  }

  // ─── 1. Daily Summary ───────────────────────────────────────────────────────
  @override
  Future<ReportEntity> getDailySummary({required String date, String? lineType, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    final start = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    final end = start.add(const Duration(hours: 23, minutes: 59, seconds: 59));
    final vars = <String, dynamic>{'start': start.toIso8601String(), 'end': end.toIso8601String()};
    String lineFilter = '';
    if (line != null && line != 'All') { lineFilter = ', customer: { line_id: {_eq: \$lineId} }'; vars['lineId'] = line; }
    final query = '''
      query GetDailySummary(\$start: timestamp!, \$end: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        collections(where: {date: {_gte: \$start, _lte: \$end}$lineFilter}, order_by: {date: desc}) {
          amount status
          customer { name line { name } }
        }
        customers_aggregate(where: { created_at: {_gte: \$start, _lte: \$end}${line != null && line != 'All' ? ', line_id: {_eq: \$lineId}' : ''} }) {
          aggregate { count }
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List cols = result.data?['collections'] ?? [];
    final int newC = result.data?['customers_aggregate']?['aggregate']?['count'] ?? 0;
    double totalCollected = 0; double totalPending = 0;
    final rows = <Map<String, String>>[];
    for (var c in cols) {
      final amount = double.tryParse(c['amount']?.toString() ?? '0') ?? 0;
      final status = c['status']?.toString() ?? 'Pending';
      final customerName = c['customer']?['name']?.toString() ?? 'Unknown';
      final lineName = c['customer']?['line']?['name']?.toString() ?? 'Unknown';
      if (status.toLowerCase() == 'paid') { totalCollected += amount; } else { totalPending += amount; }
      rows.add({'Customer': customerName, 'Line': lineName, 'Amount': _fmt(amount), 'Status': status});
    }
    return ReportEntity(title: 'Daily Summary — $date', summaryFields: {'Total Collections': cols.length.toString(), 'Collected': _fmt(totalCollected), 'Pending': _fmt(totalPending), 'New Customers': newC.toString()}, columns: ['Customer', 'Line', 'Amount', 'Status'], rows: rows);
  }

  // ─── 2. Line Summary ────────────────────────────────────────────────────────
  @override
  Future<ReportEntity> getLineSummary({required String fromDate, required String toDate, String? lineType, String? line, bool all = true}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = _dateRange(fromDate, toDate);
    if (line != null && line != 'All') { vars['lineId'] = line; }
    final query = '''
      query GetLineSummary(\$start: timestamp!, \$end: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        lines${line != null && line != 'All' ? '(where: {id: {_eq: \$lineId}})' : ''} { id name }
        loans(where: { start_date: {_gte: \$start, _lte: \$end} }) { principal_amount customer { line { id } } }
        collections(where: { date: {_gte: \$start, _lte: \$end}, status: {_eq: "Paid"} }) { amount customer { line { id } } }
        customers { line_id }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List linesData = result.data?['lines'] ?? [];
    final List loansData = result.data?['loans'] ?? [];
    final List colsData = result.data?['collections'] ?? [];
    final List custs = result.data?['customers'] ?? [];
    double totalLoan = 0; double totalCollected = 0;
    final rows = <Map<String, String>>[];
    for (var l in linesData) {
      final lid = l['id'];
      double lineLoan = loansData.where((lo) => lo['customer']?['line']?['id'] == lid).fold(0.0, (s, lo) => s + (double.tryParse(lo['principal_amount']?.toString() ?? '0') ?? 0));
      double lineCollected = colsData.where((c) => c['customer']?['line']?['id'] == lid).fold(0.0, (s, c) => s + (double.tryParse(c['amount']?.toString() ?? '0') ?? 0));
      int activeCusts = custs.where((c) => c['line_id'] == lid).length;
      totalLoan += lineLoan; totalCollected += lineCollected;
      rows.add({'Line': l['name'], 'Loan Given': _fmt(lineLoan), 'Collected': _fmt(lineCollected), 'Outstanding': _fmt(lineLoan - lineCollected), 'Customers': activeCusts.toString()});
    }
    return ReportEntity(title: 'Line Summary — $fromDate to $toDate', summaryFields: {'Total Lines': linesData.length.toString(), 'Total Loan Given': _fmt(totalLoan), 'Total Collected': _fmt(totalCollected), 'Global Outstanding': _fmt(totalLoan - totalCollected), 'Active Customers': custs.length.toString()}, columns: ['Line', 'Loan Given', 'Collected', 'Outstanding', 'Customers'], rows: rows);
  }

  // ─── 3. New Customer Summary ─────────────────────────────────────────────────
  @override
  Future<ReportEntity> getNewCustomerSummary({required String fromDate, required String toDate, String? lineType, String? line, bool all = true}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = _dateRange(fromDate, toDate);
    String lineFilter = '';
    if (line != null && line != 'All') { lineFilter = ', line_id: {_eq: \$lineId}'; vars['lineId'] = line; }
    final query = '''
      query GetNewCustomers(\$start: timestamp!, \$end: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        customers(where: {created_at: {_gte: \$start, _lte: \$end}$lineFilter}, order_by: {created_at: desc}) {
          name phone line { name } area { name } created_at
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List custs = result.data?['customers'] ?? [];
    final rows = custs.map<Map<String, String>>((c) => {'Name': c['name']?.toString() ?? '', 'Phone': c['phone']?.toString() ?? '', 'Line': c['line']?['name']?.toString() ?? '', 'Area': c['area']?['name']?.toString() ?? '', 'Joined': _fmtDate(c['created_at'])}).toList();
    return ReportEntity(title: 'New Customers — $fromDate to $toDate', summaryFields: {'Total New Customers': custs.length.toString()}, columns: ['Name', 'Phone', 'Line', 'Area', 'Joined'], rows: rows);
  }

  // ─── 4. Loan Summary ─────────────────────────────────────────────────────────
  @override
  Future<ReportEntity> getLoanSummary({required String fromDate, required String toDate, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = _dateRange(fromDate, toDate);
    String lineFilter = '';
    if (line != null && line != 'All') { lineFilter = ', customer: {line_id: {_eq: \$lineId}}'; vars['lineId'] = line; }
    final query = '''
      query GetLoanSummary(\$start: timestamp!, \$end: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        loans(where: {start_date: {_gte: \$start, _lte: \$end}$lineFilter}, order_by: {start_date: desc}) {
          id principal_amount total_amount outstanding_balance status start_date
          customer { name line { name } }
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List loansData = result.data?['loans'] ?? [];
    double totalPrincipal = 0; double totalOutstanding = 0;
    final rows = <Map<String, String>>[];
    for (var l in loansData) {
      final principal = double.tryParse(l['principal_amount']?.toString() ?? '0') ?? 0;
      final outstanding = double.tryParse(l['outstanding_balance']?.toString() ?? '0') ?? 0;
      totalPrincipal += principal; totalOutstanding += outstanding;
      rows.add({'Customer': l['customer']?['name']?.toString() ?? '', 'Line': l['customer']?['line']?['name']?.toString() ?? '', 'Principal': _fmt(principal), 'Outstanding': _fmt(outstanding), 'Status': l['status']?.toString() ?? '', 'Date': _fmtDate(l['start_date'])});
    }
    return ReportEntity(title: 'Loan Summary — $fromDate to $toDate', summaryFields: {'Total Loans': loansData.length.toString(), 'Total Principal': _fmt(totalPrincipal), 'Total Outstanding': _fmt(totalOutstanding)}, columns: ['Customer', 'Line', 'Principal', 'Outstanding', 'Status', 'Date'], rows: rows);
  }

  // ─── 5. Expense Summary ───────────────────────────────────────────────────────
  @override
  Future<ReportEntity> getExpenseSummary({required String fromDate, required String toDate, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = _dateRange(fromDate, toDate);
    vars['userId'] = userId;
    final query = '''
      query GetExpenseSummary(\$start: timestamp!, \$end: timestamp!, \$userId: uuid!) {
        expenses(where: {date: {_gte: \$start, _lte: \$end}, user_id: {_eq: \$userId}}, order_by: {date: desc}) {
          amount comments date type_id
        }
        expense_types {
          id name
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List expData = result.data?['expenses'] ?? [];
    final List typesData = result.data?['expense_types'] ?? [];
    final typesMap = {for (var t in typesData) t['id']?.toString(): t['name']?.toString()};
    double total = 0;
    final rows = <Map<String, String>>[];
    for (var e in expData) {
      final amount = double.tryParse(e['amount']?.toString() ?? '0') ?? 0;
      total += amount;
      final typeName = typesMap[e['type_id']?.toString()] ?? 'Other';
      rows.add({'Type': typeName, 'Note': e['comments']?.toString() ?? '', 'Amount': _fmt(amount), 'Date': _fmtDate(e['date'])});
    }
    return ReportEntity(title: 'Expense Summary — $fromDate to $toDate', summaryFields: {'Total Expenses': expData.length.toString(), 'Total Amount': _fmt(total)}, columns: ['Type', 'Note', 'Amount', 'Date'], rows: rows);
  }

  // ─── 6. Completed Loan Summary ────────────────────────────────────────────────
  @override
  Future<ReportEntity> getCompletedLoanSummary({required String fromDate, required String toDate, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final fromP = DateFormat('dd/MM/yyyy').parse(fromDate);
    final toP = DateFormat('dd/MM/yyyy').parse(toDate);
    final vars = {
      'start': DateFormat('yyyy-MM-dd').format(fromP),
      'end': DateFormat('yyyy-MM-dd').format(toP),
    };
    String lineFilter = '';
    if (line != null && line != 'All') { lineFilter = ', customer: {line_id: {_eq: \$lineId}}'; vars['lineId'] = line; }
    final query = '''
      query GetCompletedLoans(\$start: date!, \$end: date!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        loans(where: {status: {_eq: "Completed"}, end_date: {_gte: \$start, _lte: \$end}$lineFilter}, order_by: {end_date: desc}) {
          id principal_amount total_amount start_date end_date
          customer { name line { name } }
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List loansData = result.data?['loans'] ?? [];
    double totalPrincipal = 0; double totalAmount = 0;
    final rows = <Map<String, String>>[];
    for (var l in loansData) {
      final principal = double.tryParse(l['principal_amount']?.toString() ?? '0') ?? 0;
      final total = double.tryParse(l['total_amount']?.toString() ?? '0') ?? 0;
      totalPrincipal += principal; totalAmount += total;
      rows.add({'Customer': l['customer']?['name']?.toString() ?? '', 'Line': l['customer']?['line']?['name']?.toString() ?? '', 'Principal': _fmt(principal), 'Total Paid': _fmt(total), 'Start Date': _fmtDate(l['start_date']), 'Closed On': _fmtDate(l['end_date'])});
    }
    return ReportEntity(title: 'Completed Loans — $fromDate to $toDate', summaryFields: {'Total Completed': loansData.length.toString(), 'Principal Recovered': _fmt(totalPrincipal), 'Total Amount Collected': _fmt(totalAmount)}, columns: ['Customer', 'Line', 'Principal', 'Total Paid', 'Start Date', 'Closed On'], rows: rows);
  }

  @override
  Future<ReportEntity> getBadLoanSummary({int minDays = 150, int maxDays = 999999, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = <String, dynamic>{};
    if (line != null && line != 'All') { vars['lineId'] = line; }
    final query = '''
      query GetBadLoans${line != null && line != 'All' ? '(\$lineId: uuid)' : ''} {
        loans(where: {status: {_eq: "Active"}${line != null && line != 'All' ? ', customer: {line_id: {_eq: \$lineId}}' : ''}}) {
          id outstanding_balance start_date customer_id
          customer { name phone line { name } }
        }
        collections(where: {status: {_eq: "paid"}}) {
          customer_id date
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List loansData = result.data?['loans'] ?? [];
    final List collectionsData = result.data?['collections'] ?? [];
    final latestPaymentMap = <String, DateTime>{};
    for (var c in collectionsData) {
      final custId = c['customer_id']?.toString();
      final dateStr = c['date']?.toString();
      if (custId != null && dateStr != null) {
        final date = DateTime.parse(dateStr);
        final currentLatest = latestPaymentMap[custId];
        if (currentLatest == null || date.isAfter(currentLatest)) {
          latestPaymentMap[custId] = date;
        }
      }
    }
    final now = DateTime.now();
    double totalOutstanding = 0;
    final rows = <Map<String, String>>[];
    for (var l in loansData) {
      final custId = l['customer_id']?.toString() ?? '';
      final startDate = l['start_date'] != null ? DateTime.parse(l['start_date'].toString()) : now;
      final lastPaymentDate = latestPaymentMap[custId];
      final daysSince = lastPaymentDate != null 
          ? now.difference(lastPaymentDate).inDays 
          : now.difference(startDate).inDays;
      if (daysSince >= minDays && daysSince <= maxDays) {
        final outstanding = double.tryParse(l['outstanding_balance']?.toString() ?? '0') ?? 0;
        totalOutstanding += outstanding;
        final lastPay = lastPaymentDate != null ? _fmtDate(lastPaymentDate.toIso8601String()) : 'Never';
        rows.add({
          'Customer': l['customer']?['name']?.toString() ?? '',
          'Phone': l['customer']?['phone']?.toString() ?? '',
          'Line': l['customer']?['line']?['name']?.toString() ?? '',
          'Outstanding': _fmt(outstanding),
          'Last Payment': lastPay,
          'Days': daysSince.toString()
        });
      }
    }
    return ReportEntity(title: 'Bad Loan Summary (>${minDays}d)', summaryFields: {'Total Bad Loans': rows.length.toString(), 'Total Outstanding': _fmt(totalOutstanding)}, columns: ['Customer', 'Phone', 'Line', 'Outstanding', 'Last Payment', 'Days'], rows: rows);
  }

  // ─── 8. Missing Customer Summary ─────────────────────────────────────────────
  @override
  Future<ReportEntity> getMissingCustomerSummary({required String date, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    final start = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    final end = start.add(const Duration(hours: 23, minutes: 59, seconds: 59));
    final vars = <String, dynamic>{'start': start.toIso8601String(), 'end': end.toIso8601String()};
    String lineFilter = '';
    if (line != null && line != 'All') { lineFilter = ', line_id: {_eq: \$lineId}'; vars['lineId'] = line; }
    final query = '''
      query GetMissingCustomers(\$start: timestamp!, \$end: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        customers${line != null && line != 'All' ? '(where: {line_id: {_eq: \$lineId}})' : ''} {
          id name phone
          line { name }
          area { name }
        }
        collections(where: {date: {_gte: \$start, _lte: \$end}}) {
          customer_id
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List custsData = result.data?['customers'] ?? [];
    final List colsData = result.data?['collections'] ?? [];
    final paidCustomerIds = colsData.map((c) => c['customer_id']?.toString()).toSet();
    final missingCusts = custsData.where((c) => !paidCustomerIds.contains(c['id']?.toString())).toList();
    final rows = missingCusts.map<Map<String, String>>((c) => {'Name': c['name']?.toString() ?? '', 'Phone': c['phone']?.toString() ?? '', 'Line': c['line']?['name']?.toString() ?? '', 'Area': c['area']?['name']?.toString() ?? ''}).toList();
    return ReportEntity(title: 'Missing Customers — $date', summaryFields: {'Missing Count': missingCusts.length.toString()}, columns: ['Name', 'Phone', 'Line', 'Area'], rows: rows);
  }

  // ─── 9. Investment Summary ────────────────────────────────────────────────────
  @override
  Future<ReportEntity> getInvestmentSummary({required String fromDate, required String toDate, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = _dateRange(fromDate, toDate);
    vars['userId'] = userId;
    final query = '''
      query GetInvestmentSummary(\$start: timestamp!, \$end: timestamp!, \$userId: uuid!) {
        investments(where: {date: {_gte: \$start, _lte: \$end}, user_id: {_eq: \$userId}}, order_by: {date: desc}) {
          amount comments date type_id
        }
        investment_types {
          id name
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List invData = result.data?['investments'] ?? [];
    final List typesData = result.data?['investment_types'] ?? [];
    final typesMap = {for (var t in typesData) t['id']?.toString(): t['name']?.toString()};
    double total = 0;
    final rows = <Map<String, String>>[];
    for (var inv in invData) {
      final amount = double.tryParse(inv['amount']?.toString() ?? '0') ?? 0;
      total += amount;
      final typeName = typesMap[inv['type_id']?.toString()] ?? 'Other';
      rows.add({'Type': typeName, 'Note': inv['comments']?.toString() ?? '', 'Amount': _fmt(amount), 'Date': _fmtDate(inv['date'])});
    }
    return ReportEntity(title: 'Investment Summary — $fromDate to $toDate', summaryFields: {'Total Investments': invData.length.toString(), 'Total Amount': _fmt(total)}, columns: ['Type', 'Note', 'Amount', 'Date'], rows: rows);
  }

  // ─── 10. Investment/Expense Summary ──────────────────────────────────────────
  @override
  Future<ReportEntity> getInvestmentExpenseSummary({required String fromDate, required String toDate}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = _dateRange(fromDate, toDate);
    vars['userId'] = userId;
    final query = '''
      query GetInvestExpenseSummary(\$start: timestamp!, \$end: timestamp!, \$userId: uuid!) {
        investments(where: {date: {_gte: \$start, _lte: \$end}, user_id: {_eq: \$userId}}) {
          amount
        }
        expenses(where: {date: {_gte: \$start, _lte: \$end}, user_id: {_eq: \$userId}}) {
          amount
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List invData = result.data?['investments'] ?? [];
    final List expData = result.data?['expenses'] ?? [];
    double totalInv = invData.fold(0.0, (s, i) => s + (double.tryParse(i['amount']?.toString() ?? '0') ?? 0));
    double totalExp = expData.fold(0.0, (s, e) => s + (double.tryParse(e['amount']?.toString() ?? '0') ?? 0));
    final rows = [
      {'Category': 'Investment', 'Count': invData.length.toString(), 'Total': _fmt(totalInv)},
      {'Category': 'Expense', 'Count': expData.length.toString(), 'Total': _fmt(totalExp)},
    ];
    return ReportEntity(title: 'Investment/Expense — $fromDate to $toDate', summaryFields: {'Total Investment': _fmt(totalInv), 'Total Expense': _fmt(totalExp), 'Net': _fmt(totalInv - totalExp)}, columns: ['Category', 'Count', 'Total'], rows: rows);
  }

  // ─── 11. Ledger Report (customer payment history) ─────────────────────────────
  @override
  Future<ReportEntity> getLedgerReport({required String fromDate, required String toDate, String? lineId}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = _dateRange(fromDate, toDate);
    String lineFilter = '';
    if (lineId != null && lineId != 'All') { lineFilter = ', customer: {line_id: {_eq: \$lineId}}'; vars['lineId'] = lineId; }
    final query = '''
      query GetLedger(\$start: timestamp!, \$end: timestamp!${lineId != null && lineId != 'All' ? ', \$lineId: uuid' : ''}) {
        collections(where: {date: {_gte: \$start, _lte: \$end}$lineFilter}, order_by: {date: desc}) {
          date amount status
          customer { name line { name } area { name } }
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List colsData = result.data?['collections'] ?? [];
    double totalCollected = 0;
    final rows = <Map<String, String>>[];
    for (var c in colsData) {
      final amount = double.tryParse(c['amount']?.toString() ?? '0') ?? 0;
      if ((c['status']?.toString() ?? '').toLowerCase() == 'paid') totalCollected += amount;
      rows.add({'Date': _fmtDate(c['date']), 'Customer': c['customer']?['name']?.toString() ?? '', 'Line': c['customer']?['line']?['name']?.toString() ?? '', 'Area': c['customer']?['area']?['name']?.toString() ?? '', 'Amount': _fmt(amount), 'Status': c['status']?.toString() ?? ''});
    }
    return ReportEntity(title: 'Ledger — $fromDate to $toDate', summaryFields: {'Total Entries': colsData.length.toString(), 'Total Collected': _fmt(totalCollected)}, columns: ['Date', 'Customer', 'Line', 'Area', 'Amount', 'Status'], rows: rows);
  }

  // ─── 12. About to Close Loan ──────────────────────────────────────────────────
  @override
  Future<ReportEntity> getAboutToCloseLoanSummary({int withinDays = 30, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = <String, dynamic>{};
    String lineFilter = '';
    if (line != null && line != 'All') { lineFilter = ', customer: {line_id: {_eq: \$lineId}}'; vars['lineId'] = line; }
    final query = '''
      query GetAboutToClose${line != null && line != 'All' ? '(\$lineId: uuid)' : ''} {
        loans(where: {status: {_eq: "Active"}$lineFilter}, order_by: {outstanding_balance: asc}) {
          id outstanding_balance daily_due_amount start_date
          customer { name phone line { name } }
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List loansData = result.data?['loans'] ?? [];
    final rows = <Map<String, String>>[];
    for (var l in loansData) {
      final outstanding = double.tryParse(l['outstanding_balance']?.toString() ?? '0') ?? 0;
      final daily = double.tryParse(l['daily_due_amount']?.toString() ?? '1') ?? 1;
      final daysLeft = daily > 0 ? (outstanding / daily).ceil() : 0;
      if (daysLeft <= withinDays) {
        rows.add({'Customer': l['customer']?['name']?.toString() ?? '', 'Phone': l['customer']?['phone']?.toString() ?? '', 'Line': l['customer']?['line']?['name']?.toString() ?? '', 'Outstanding': _fmt(outstanding), 'Days Left': daysLeft.toString()});
      }
    }
    return ReportEntity(title: 'About to Close (within ${withinDays}d)', summaryFields: {'Loans Closing Soon': rows.length.toString()}, columns: ['Customer', 'Phone', 'Line', 'Outstanding', 'Days Left'], rows: rows);
  }

  // ─── 13. Monthly Interest Pending ─────────────────────────────────────────────
  @override
  Future<ReportEntity> getMonthlyInterestPendingSummary({required int month, required int year, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    final vars = <String, dynamic>{'start': start.toIso8601String(), 'end': end.toIso8601String()};
    String lineFilter = '';
    if (line != null && line != 'All') { lineFilter = ', customer: {line_id: {_eq: \$lineId}}'; vars['lineId'] = line; }
    final query = '''
      query GetMonthlyPending(\$start: timestamp!, \$end: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        collections(where: {date: {_gte: \$start, _lte: \$end}, status: {_neq: "Paid"}$lineFilter}, order_by: {date: desc}) {
          date amount status
          customer { name phone line { name } }
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List colsData = result.data?['collections'] ?? [];
    final rows = colsData.map<Map<String, String>>((c) => {'Customer': c['customer']?['name']?.toString() ?? '', 'Phone': c['customer']?['phone']?.toString() ?? '', 'Line': c['customer']?['line']?['name']?.toString() ?? '', 'Status': c['status']?.toString() ?? '', 'Date': _fmtDate(c['date'])}).toList();
    return ReportEntity(title: 'Monthly Interest Pending — ${DateFormat('MMMM yyyy').format(start)}', summaryFields: {'Pending Entries': colsData.length.toString()}, columns: ['Customer', 'Phone', 'Line', 'Status', 'Date'], rows: rows);
  }

  @override
  Future<ReportEntity> getNonPerformanceLoanSummary({int minDays = 90, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = <String, dynamic>{};
    if (line != null && line != 'All') { vars['lineId'] = line; }
    final query = '''
      query GetNonPerformance${line != null && line != 'All' ? '(\$lineId: uuid)' : ''} {
        loans(where: {status: {_eq: "Active"}${line != null && line != 'All' ? ', customer: {line_id: {_eq: \$lineId}}' : ''}}) {
          outstanding_balance start_date customer_id
          customer { name phone line { name } }
        }
        collections(where: {status: {_eq: "paid"}}) {
          customer_id date
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List loansData = result.data?['loans'] ?? [];
    final List collectionsData = result.data?['collections'] ?? [];
    final latestPaymentMap = <String, DateTime>{};
    for (var c in collectionsData) {
      final custId = c['customer_id']?.toString();
      final dateStr = c['date']?.toString();
      if (custId != null && dateStr != null) {
        final date = DateTime.parse(dateStr);
        final currentLatest = latestPaymentMap[custId];
        if (currentLatest == null || date.isAfter(currentLatest)) {
          latestPaymentMap[custId] = date;
        }
      }
    }
    final now = DateTime.now();
    double totalOutstanding = 0;
    final rows = <Map<String, String>>[];
    for (var l in loansData) {
      final custId = l['customer_id']?.toString() ?? '';
      final startDate = l['start_date'] != null ? DateTime.parse(l['start_date'].toString()) : now;
      final lastPaymentDate = latestPaymentMap[custId];
      final days = lastPaymentDate != null 
          ? now.difference(lastPaymentDate).inDays 
          : now.difference(startDate).inDays;
      if (days >= minDays) {
        final outstanding = double.tryParse(l['outstanding_balance']?.toString() ?? '0') ?? 0;
        totalOutstanding += outstanding;
        final lastPay = lastPaymentDate != null ? _fmtDate(lastPaymentDate.toIso8601String()) : 'Never';
        rows.add({
          'Customer': l['customer']?['name']?.toString() ?? '',
          'Phone': l['customer']?['phone']?.toString() ?? '',
          'Line': l['customer']?['line']?['name']?.toString() ?? '',
          'Outstanding': _fmt(outstanding),
          'Last Payment': lastPay,
          'Days Idle': days.toString()
        });
      }
    }
    return ReportEntity(title: 'Non-Performance Loans (>${minDays}d idle)', summaryFields: {'Total NPA Loans': rows.length.toString(), 'Total Outstanding': _fmt(totalOutstanding)}, columns: ['Customer', 'Phone', 'Line', 'Outstanding', 'Last Payment', 'Days Idle'], rows: rows);
  }

  @override
  Future<ReportEntity> getNewBadLoanByDateSummary({required String fromDate, required String toDate, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final parsedFrom = DateFormat('dd/MM/yyyy').parse(fromDate);
    final parsedTo = DateFormat('dd/MM/yyyy').parse(toDate);
    final rangeStart = DateTime(parsedFrom.year, parsedFrom.month, parsedFrom.day);
    final rangeEnd = DateTime(parsedTo.year, parsedTo.month, parsedTo.day, 23, 59, 59);
    final vars = <String, dynamic>{};
    if (line != null && line != 'All') { vars['lineId'] = line; }
    final query = '''
      query GetNewBadLoans${line != null && line != 'All' ? '(\$lineId: uuid)' : ''} {
        loans(where: {status: {_eq: "Active"}${line != null && line != 'All' ? ', customer: {line_id: {_eq: \$lineId}}' : ''}}) {
          outstanding_balance start_date customer_id
          customer { name phone line { name } }
        }
        collections(where: {status: {_eq: "paid"}}) {
          customer_id date
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List loansData = result.data?['loans'] ?? [];
    final List collectionsData = result.data?['collections'] ?? [];
    final latestPaymentMap = <String, DateTime>{};
    for (var c in collectionsData) {
      final custId = c['customer_id']?.toString();
      final dateStr = c['date']?.toString();
      if (custId != null && dateStr != null) {
        final date = DateTime.parse(dateStr);
        final currentLatest = latestPaymentMap[custId];
        if (currentLatest == null || date.isAfter(currentLatest)) {
          latestPaymentMap[custId] = date;
        }
      }
    }
    double totalOutstanding = 0;
    final rows = <Map<String, String>>[];
    for (var l in loansData) {
      final custId = l['customer_id']?.toString() ?? '';
      final lastPaymentDate = latestPaymentMap[custId];
      if (lastPaymentDate != null && lastPaymentDate.isAfter(rangeStart) && lastPaymentDate.isBefore(rangeEnd)) {
        final outstanding = double.tryParse(l['outstanding_balance']?.toString() ?? '0') ?? 0;
        totalOutstanding += outstanding;
        rows.add({
          'Customer': l['customer']?['name']?.toString() ?? '',
          'Phone': l['customer']?['phone']?.toString() ?? '',
          'Line': l['customer']?['line']?['name']?.toString() ?? '',
          'Outstanding': _fmt(outstanding),
          'Last Payment': _fmtDate(lastPaymentDate.toIso8601String())
        });
      }
    }
    return ReportEntity(title: 'New Bad Loans — $fromDate to $toDate', summaryFields: {'Count': rows.length.toString(), 'Total Outstanding': _fmt(totalOutstanding)}, columns: ['Customer', 'Phone', 'Line', 'Outstanding', 'Last Payment'], rows: rows);
  }

  @override
  Future<ReportEntity> getLoanAnalysis({required String fromDate, required String toDate, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final fromP = DateFormat('dd/MM/yyyy').parse(fromDate);
    final toP = DateFormat('dd/MM/yyyy').parse(toDate);
    final vars = {
      'start_date': DateFormat('yyyy-MM-dd').format(fromP),
      'end_date': DateFormat('yyyy-MM-dd').format(toP),
      'start_timestamp': fromP.toIso8601String(),
      'end_timestamp': DateTime(toP.year, toP.month, toP.day, 23, 59, 59).toIso8601String(),
    };
    String lineFilter = '';
    if (line != null && line != 'All') { lineFilter = ', customer: {line_id: {_eq: \$lineId}}'; vars['lineId'] = line; }
    final query = '''
      query GetLoanAnalysis(\$start_date: date!, \$end_date: date!, \$start_timestamp: timestamp!, \$end_timestamp: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        active: loans_aggregate(where: {status: {_eq: "Active"}$lineFilter}) { aggregate { count sum { principal_amount outstanding_balance } } }
        completed: loans_aggregate(where: {status: {_eq: "Completed"}, end_date: {_gte: \$start_date, _lte: \$end_date}$lineFilter}) { aggregate { count sum { total_amount } } }
        new_loans: loans_aggregate(where: {start_date: {_gte: \$start_timestamp, _lte: \$end_timestamp}$lineFilter}) { aggregate { count sum { principal_amount } } }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final activeAgg = result.data?['active']?['aggregate'];
    final completedAgg = result.data?['completed']?['aggregate'];
    final newLoansAgg = result.data?['new_loans']?['aggregate'];
    final activeCount = activeAgg?['count'] ?? 0;
    final activePrincipal = double.tryParse(activeAgg?['sum']?['principal_amount']?.toString() ?? '0') ?? 0;
    final activeOutstanding = double.tryParse(activeAgg?['sum']?['outstanding_balance']?.toString() ?? '0') ?? 0;
    final completedCount = completedAgg?['count'] ?? 0;
    final completedTotal = double.tryParse(completedAgg?['sum']?['total_amount']?.toString() ?? '0') ?? 0;
    final newCount = newLoansAgg?['count'] ?? 0;
    final newPrincipal = double.tryParse(newLoansAgg?['sum']?['principal_amount']?.toString() ?? '0') ?? 0;
    final rows = [
      {'Category': 'Active Loans', 'Count': activeCount.toString(), 'Amount': _fmt(activePrincipal), 'Outstanding': _fmt(activeOutstanding)},
      {'Category': 'New Loans (Period)', 'Count': newCount.toString(), 'Amount': _fmt(newPrincipal), 'Outstanding': 'N/A'},
      {'Category': 'Completed (Period)', 'Count': completedCount.toString(), 'Amount': _fmt(completedTotal), 'Outstanding': '₹0'},
    ];
    return ReportEntity(title: 'Loan Analysis — $fromDate to $toDate', summaryFields: {'Active Loans': activeCount.toString(), 'Active Outstanding': _fmt(activeOutstanding), 'Completed (Period)': completedCount.toString(), 'New Loans (Period)': newCount.toString()}, columns: ['Category', 'Count', 'Amount', 'Outstanding'], rows: rows);
  }

  // ─── 17. Online Collection Summary ───────────────────────────────────────────
  @override
  Future<ReportEntity> getOnlineCollectionSummary({required String fromDate, required String toDate, String? line}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = _dateRange(fromDate, toDate);
    String lineFilter = '';
    if (line != null && line != 'All') { lineFilter = ', customer: {line_id: {_eq: \$lineId}}'; vars['lineId'] = line; }
    final query = '''
      query GetOnlineCollections(\$start: timestamp!, \$end: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        collections(where: {date: {_gte: \$start, _lte: \$end}, status: {_eq: "Paid"}$lineFilter}, order_by: {date: desc}) {
          date amount notes
          customer { name line { name } }
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final List colsData = result.data?['collections'] ?? [];
    double total = 0;
    final rows = <Map<String, String>>[];
    for (var c in colsData) {
      final notes = (c['notes']?.toString() ?? '').toLowerCase();
      if (notes.contains('online') || notes.contains('gpay') || notes.contains('phonepe') || notes.contains('upi') || notes.contains('netbanking')) {
        final amount = double.tryParse(c['amount']?.toString() ?? '0') ?? 0;
        total += amount;
        rows.add({'Date': _fmtDate(c['date']), 'Customer': c['customer']?['name']?.toString() ?? '', 'Line': c['customer']?['line']?['name']?.toString() ?? '', 'Amount': _fmt(amount), 'Notes': c['notes']?.toString() ?? ''});
      }
    }
    return ReportEntity(title: 'Online Collections — $fromDate to $toDate', summaryFields: {'Total Online Collections': rows.length.toString(), 'Total Amount': _fmt(total)}, columns: ['Date', 'Customer', 'Line', 'Amount', 'Notes'], rows: rows);
  }

  // ─── 18. Site Dashboard Summary ───────────────────────────────────────────────
  @override
  Future<ReportEntity> getSiteDashboardSummary({required String date}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    final start = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    final end = start.add(const Duration(hours: 23, minutes: 59, seconds: 59));
    final vars = <String, dynamic>{'start': start.toIso8601String(), 'end': end.toIso8601String(), 'userId': userId};
    final query = '''
      query GetSiteDashboard(\$start: timestamp!, \$end: timestamp!, \$userId: uuid!) {
        collections_aggregate(where: {date: {_gte: \$start, _lte: \$end}, status: {_eq: "Paid"}}) { aggregate { count sum { amount } } }
        loans_aggregate(where: {status: {_eq: "Active"}}) { aggregate { count sum { outstanding_balance principal_amount } } }
        customers_aggregate { aggregate { count } }
        expenses_aggregate(where: {date: {_gte: \$start, _lte: \$end}, user_id: {_eq: \$userId}}) { aggregate { sum { amount } } }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final colAgg = result.data?['collections_aggregate']?['aggregate'];
    final loanAgg = result.data?['loans_aggregate']?['aggregate'];
    final custAgg = result.data?['customers_aggregate']?['aggregate'];
    final expAgg = result.data?['expenses_aggregate']?['aggregate'];
    final todayCollected = double.tryParse(colAgg?['sum']?['amount']?.toString() ?? '0') ?? 0;
    final todayExpenses = double.tryParse(expAgg?['sum']?['amount']?.toString() ?? '0') ?? 0;
    final totalOutstanding = double.tryParse(loanAgg?['sum']?['outstanding_balance']?.toString() ?? '0') ?? 0;
    final totalPrincipal = double.tryParse(loanAgg?['sum']?['principal_amount']?.toString() ?? '0') ?? 0;
    final rows = [
      {'Metric': 'Today\'s Collections', 'Value': colAgg?['count']?.toString() ?? '0', 'Amount': _fmt(todayCollected)},
      {'Metric': 'Today\'s Expenses', 'Value': '—', 'Amount': _fmt(todayExpenses)},
      {'Metric': 'Active Loans', 'Value': loanAgg?['count']?.toString() ?? '0', 'Amount': _fmt(totalPrincipal)},
      {'Metric': 'Total Outstanding', 'Value': '—', 'Amount': _fmt(totalOutstanding)},
      {'Metric': 'Active Customers', 'Value': custAgg?['count']?.toString() ?? '0', 'Amount': '—'},
    ];
    return ReportEntity(title: 'Site Dashboard — $date', summaryFields: {'Today Collected': _fmt(todayCollected), 'Today Expenses': _fmt(todayExpenses), 'Active Loans': loanAgg?['count']?.toString() ?? '0', 'Total Outstanding': _fmt(totalOutstanding), 'Active Customers': custAgg?['count']?.toString() ?? '0'}, columns: ['Metric', 'Value', 'Amount'], rows: rows);
  }

  // ─── 19. Book Excess/Loss Summary ────────────────────────────────────────────
  @override
  Future<ReportEntity> getBookExcessLossSummary({required String fromDate, required String toDate}) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');
    final vars = _dateRange(fromDate, toDate);
    vars['userId'] = userId;
    final query = '''
      query GetBookExcessLoss(\$start: timestamp!, \$end: timestamp!, \$userId: uuid!) {
        collections_agg: collections_aggregate(where: {date: {_gte: \$start, _lte: \$end}, status: {_eq: "Paid"}}) { aggregate { sum { amount } } }
        expenses_agg: expenses_aggregate(where: {date: {_gte: \$start, _lte: \$end}, user_id: {_eq: \$userId}}) { aggregate { sum { amount } } }
        investments_agg: investments_aggregate(where: {date: {_gte: \$start, _lte: \$end}, user_id: {_eq: \$userId}}) { aggregate { sum { amount } } }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query), variables: vars, fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());
    final collected = double.tryParse(result.data?['collections_agg']?['aggregate']?['sum']?['amount']?.toString() ?? '0') ?? 0;
    final expenses = double.tryParse(result.data?['expenses_agg']?['aggregate']?['sum']?['amount']?.toString() ?? '0') ?? 0;
    final investments = double.tryParse(result.data?['investments_agg']?['aggregate']?['sum']?['amount']?.toString() ?? '0') ?? 0;
    final net = collected - expenses - investments;
    final rows = [
      {'Category': 'Total Collected', 'Amount': _fmt(collected)},
      {'Category': 'Total Expenses', 'Amount': _fmt(expenses)},
      {'Category': 'Total Investments', 'Amount': _fmt(investments)},
      {'Category': 'Net (Excess/Loss)', 'Amount': _fmt(net)},
    ];
    return ReportEntity(title: 'Book Excess/Loss — $fromDate to $toDate', summaryFields: {'Total Collected': _fmt(collected), 'Total Expenses': _fmt(expenses), 'Total Investments': _fmt(investments), 'Net': '${net >= 0 ? "Excess" : "Loss"} ${_fmt(net.abs())}'}, columns: ['Category', 'Amount'], rows: rows);
  }
}
