import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/loan_entity.dart';
import 'loan_remote_datasource.dart';

class HasuraLoanRemoteDataSourceImpl implements LoanRemoteDataSource {
  final GraphQLClient client;
  final StorageService storageService;

  HasuraLoanRemoteDataSourceImpl({required this.client, required this.storageService});

  @override
  Future<LoanEntity> addLoan(LoanEntity loan) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    const String mutation = '''
      mutation InsertLoan(\$object: loans_insert_input!) {
        insert_loans_one(object: \$object) {
          id
          customer_id
          principal_amount
          interest_amount
          total_amount
          daily_due_amount
          outstanding_balance
          start_date
          end_date
          status
          created_at
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'object': {
          'customer_id': loan.customerId,
          'principal_amount': loan.principalAmount,
          'interest_amount': loan.interestAmount,
          'total_amount': loan.totalAmount,
          'daily_due_amount': loan.dailyDueAmount,
          'outstanding_balance': loan.outstandingBalance,
          'start_date': loan.startDate.toIso8601String().split('T')[0],
          'end_date': loan.endDate.toIso8601String().split('T')[0],
          'status': loan.status,
          'user_id': userId,
        }
      },
    );

    try {
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        throw ServerException(result.exception.toString());
      }

      final data = result.data?['insert_loans_one'];
      if (data == null) throw const ServerException('Failed to add loan.');

      return _mapJsonToEntity(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LoanEntity>> getAllLoans() async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    const String query = '''
      query GetAllLoans(\$userId: uuid!) {
        loans(where: {user_id: {_eq: \$userId}}, order_by: { created_at: desc }) {
          id
          customer_id
          principal_amount
          interest_amount
          total_amount
          daily_due_amount
          outstanding_balance
          start_date
          end_date
          status
          created_at
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {
        'userId': userId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final QueryResult result = await client.query(options);

      if (result.hasException) {
        throw ServerException(result.exception.toString());
      }

      final List<dynamic> loansData = result.data?['loans'] ?? [];
      return loansData.map((json) => _mapJsonToEntity(json)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LoanEntity>> getLoansByCustomer(String customerId) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    const String query = '''
      query GetLoansByCustomer(\$customerId: uuid!, \$userId: uuid!) {
        loans(where: { customer_id: { _eq: \$customerId }, user_id: { _eq: \$userId } }, order_by: { created_at: desc }) {
          id
          customer_id
          principal_amount
          interest_amount
          total_amount
          daily_due_amount
          outstanding_balance
          start_date
          end_date
          status
          created_at
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {
        'customerId': customerId,
        'userId': userId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final QueryResult result = await client.query(options);

      if (result.hasException) {
        throw ServerException(result.exception.toString());
      }

      final List<dynamic> loansData = result.data?['loans'] ?? [];
      return loansData.map((json) => _mapJsonToEntity(json)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  LoanEntity _mapJsonToEntity(Map<String, dynamic> json) {
    return LoanEntity(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      principalAmount: double.tryParse(json['principal_amount'].toString()) ?? 0.0,
      interestAmount: double.tryParse(json['interest_amount'].toString()) ?? 0.0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      dailyDueAmount: double.tryParse(json['daily_due_amount'].toString()) ?? 0.0,
      outstandingBalance: double.tryParse(json['outstanding_balance'].toString()) ?? 0.0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'] as String? ?? 'Active',
    );
  }
}
