import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:intl/intl.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/report_entity.dart';
import 'report_remote_datasource.dart';

class HasuraReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final GraphQLClient client;

  HasuraReportRemoteDataSourceImpl({required this.client});

  @override
  Future<ReportEntity> getDailySummary({
    required String date,
    String? lineType,
    String? line,
  }) async {
    // date format is usually dd/MM/yyyy from UI. Let's parse it to start and end of day.
    final parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    final startOfDay = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    final endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

    final Map<String, dynamic> variables = {
      'start': startOfDay.toIso8601String(),
      'end': endOfDay.toIso8601String(),
    };
    
    String lineFilter = '';
    if (line != null && line != 'All') {
      lineFilter = ', customer: { line_id: {_eq: \$lineId} }';
      variables['lineId'] = line;
    }

    final query = '''
      query GetDailySummary(\$start: timestamp!, \$end: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        collections(where: {
          date: {_gte: \$start, _lte: \$end}
          $lineFilter
        }, order_by: {date: desc}) {
          amount
          status
          customer {
            name
            line { name }
          }
        }
        customers_aggregate(where: {
          created_at: {_gte: \$start, _lte: \$end}
          ${line != null && line != 'All' ? 'line_id: {_eq: \$lineId}' : ''}
        }) {
          aggregate { count }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final List collections = result.data?['collections'] ?? [];
    final int newCustomersCount = result.data?['customers_aggregate']?['aggregate']?['count'] ?? 0;

    double totalCollected = 0;
    double totalPending = 0;
    
    final List<Map<String, String>> rows = [];

    for (var c in collections) {
      final amount = double.tryParse(c['amount']?.toString() ?? '0') ?? 0;
      final status = c['status']?.toString() ?? 'Pending';
      final customerName = c['customer']?['name']?.toString() ?? 'Unknown';
      final lineName = c['customer']?['line']?['name']?.toString() ?? 'Unknown';

      if (status.toLowerCase() == 'paid') {
        totalCollected += amount;
      } else {
        totalPending += amount; // We don't have expected amount, just counting what they entered if pending
      }

      rows.add({
        'Customer': customerName,
        'Line': lineName,
        'Amount': '₹${amount.toStringAsFixed(0)}',
        'Status': status,
      });
    }

    return ReportEntity(
      title: 'Daily Summary — $date',
      summaryFields: {
        'Total Collections': collections.length.toString(),
        'Collected Amount': '₹${totalCollected.toStringAsFixed(0)}',
        'New Customers': newCustomersCount.toString(),
      },
      columns: ['Customer', 'Line', 'Amount', 'Status'],
      rows: rows,
    );
  }

  @override
  Future<ReportEntity> getLineSummary({
    required String fromDate,
    required String toDate,
    String? lineType,
    String? line,
    bool all = true,
  }) async {
    final fromParsed = DateFormat('dd/MM/yyyy').parse(fromDate);
    final toParsed = DateFormat('dd/MM/yyyy').parse(toDate);
    final endOfDay = DateTime(toParsed.year, toParsed.month, toParsed.day, 23, 59, 59);

    final Map<String, dynamic> variables = {
      'start': fromParsed.toIso8601String(),
      'end': endOfDay.toIso8601String(),
    };

    String lineFilter = '';
    if (line != null && line != 'All') {
      lineFilter = 'id: {_eq: \$lineId}';
      variables['lineId'] = line;
    }

    // Fetch lines, and aggregate their loans/collections
    final query = '''
      query GetLineSummary(\$start: timestamp!, \$end: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        lines${line != null && line != 'All' ? '(where: {id: {_eq: \$lineId}})' : ''} {
          id
          name
        }
        loans(where: { start_date: {_gte: \$start, _lte: \$end} }) {
          principal_amount
          customer { line { id } }
        }
        collections(where: { date: {_gte: \$start, _lte: \$end}, status: {_eq: "Paid"} }) {
          amount
          customer { line { id } }
        }
        customers(where: { is_active: {_eq: true} }) {
          line_id
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final List linesData = result.data?['lines'] ?? [];
    final List loansData = result.data?['loans'] ?? [];
    final List collectionsData = result.data?['collections'] ?? [];
    final List customersData = result.data?['customers'] ?? [];

    double totalGlobalLoan = 0;
    double totalGlobalCollected = 0;
    
    final List<Map<String, String>> rows = [];

    for (var l in linesData) {
      final lineId = l['id'];
      final lineName = l['name'];

      double lineLoan = 0;
      for (var loan in loansData) {
        if (loan['customer']?['line']?['id'] == lineId) {
          lineLoan += double.tryParse(loan['principal_amount']?.toString() ?? '0') ?? 0;
        }
      }

      double lineCollected = 0;
      for (var col in collectionsData) {
        if (col['customer']?['line']?['id'] == lineId) {
          lineCollected += double.tryParse(col['amount']?.toString() ?? '0') ?? 0;
        }
      }

      int activeCustomers = customersData.where((c) => c['line_id'] == lineId).length;

      totalGlobalLoan += lineLoan;
      totalGlobalCollected += lineCollected;

      rows.add({
        'Line': lineName,
        'Loan Given': '₹${lineLoan.toStringAsFixed(0)}',
        'Collected': '₹${lineCollected.toStringAsFixed(0)}',
        'Outstanding': '₹${(lineLoan - lineCollected).toStringAsFixed(0)}',
        'Customers': activeCustomers.toString(),
      });
    }

    return ReportEntity(
      title: 'Line Summary — $fromDate to $toDate',
      summaryFields: {
        'Total Lines': linesData.length.toString(),
        'Total Loan Given': '₹${totalGlobalLoan.toStringAsFixed(0)}',
        'Total Collected': '₹${totalGlobalCollected.toStringAsFixed(0)}',
        'Global Outstanding': '₹${(totalGlobalLoan - totalGlobalCollected).toStringAsFixed(0)}',
        'Active Customers': customersData.length.toString(),
      },
      columns: ['Line', 'Loan Given', 'Collected', 'Outstanding', 'Customers'],
      rows: rows,
    );
  }

  @override
  Future<ReportEntity> getNewCustomerSummary({
    required String fromDate,
    required String toDate,
    String? lineType,
    String? line,
    bool all = true,
  }) async {
    final fromParsed = DateFormat('dd/MM/yyyy').parse(fromDate);
    final toParsed = DateFormat('dd/MM/yyyy').parse(toDate);
    final endOfDay = DateTime(toParsed.year, toParsed.month, toParsed.day, 23, 59, 59);

    final Map<String, dynamic> variables = {
      'start': fromParsed.toIso8601String(),
      'end': endOfDay.toIso8601String(),
    };

    String lineFilter = '';
    if (line != null && line != 'All') {
      lineFilter = ', line_id: {_eq: \$lineId}';
      variables['lineId'] = line;
    }

    final query = '''
      query GetNewCustomers(\$start: timestamp!, \$end: timestamp!${line != null && line != 'All' ? ', \$lineId: uuid' : ''}) {
        customers(where: {
          created_at: {_gte: \$start, _lte: \$end}
          $lineFilter
        }, order_by: {created_at: desc}) {
          name
          phone
          line { name }
          area { name }
          created_at
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final List customersData = result.data?['customers'] ?? [];
    final List<Map<String, String>> rows = [];

    for (var c in customersData) {
      final joined = DateTime.parse(c['created_at']);
      
      rows.add({
        'Name': c['name']?.toString() ?? 'Unknown',
        'Phone': c['phone']?.toString() ?? 'N/A',
        'Line': c['line']?['name']?.toString() ?? 'N/A',
        'Area': c['area']?['name']?.toString() ?? 'N/A',
        'Date Joined': DateFormat('dd/MM/yyyy').format(joined),
      });
    }

    return ReportEntity(
      title: 'New Customers — $fromDate to $toDate',
      summaryFields: {
        'Total New Customers': customersData.length.toString(),
      },
      columns: ['Name', 'Phone', 'Line', 'Area', 'Date Joined'],
      rows: rows,
    );
  }
}
