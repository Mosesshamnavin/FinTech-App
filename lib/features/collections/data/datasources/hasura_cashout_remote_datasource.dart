import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/storage_service.dart';
import '../models/cashout_model.dart';
import 'cashout_remote_datasource.dart';

class HasuraCashOutRemoteDataSourceImpl implements CashOutRemoteDataSource {
  final GraphQLClient client;
  final StorageService storageService;

  HasuraCashOutRemoteDataSourceImpl({
    required this.client,
    required this.storageService,
  });

  @override
  Future<CashOutModel> addCashOut(CashOutModel cashOut) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    const String mutation = '''
      mutation AddCashOut(\$object: cashouts_insert_input!) {
        insert_cashouts_one(object: \$object) {
          id
          line_id
          amount
          date
          name
          comments
          is_active
          created_at
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'object': {
            'line_id': cashOut.lineId,
            'amount': cashOut.amount,
            'date': cashOut.date.toIso8601String(),
            'name': cashOut.name,
            'comments': cashOut.comments,
            'is_active': true,
            'user_id': userId,
          }
        },
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final data = result.data?['insert_cashouts_one'];
    if (data == null) throw const ServerException('Failed to add cash out.');

    return _mapToCashOutModel(data);
  }

  @override
  Future<List<CashOutModel>> getActiveCashOuts(String? lineId) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    Map<String, dynamic> whereClause = {
      'is_active': {'_eq': true},
      'user_id': {'_eq': userId},
    };
    if (lineId != null && lineId.isNotEmpty) {
      whereClause['line_id'] = {'_eq': lineId};
    }

    const String query = '''
      query GetActiveCashOuts(\$where: cashouts_bool_exp!) {
        cashouts(where: \$where, order_by: {created_at: desc}) {
          id
          line_id
          amount
          date
          name
          comments
          is_active
          created_at
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'where': whereClause},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final List data = result.data?['cashouts'] ?? [];
    return data.map((json) => _mapToCashOutModel(json)).toList();
  }

  @override
  Future<List<CashOutModel>> getCashOutHistory(String? lineId) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    Map<String, dynamic> whereClause = {
      'is_active': {'_eq': false},
      'user_id': {'_eq': userId},
    };
    if (lineId != null && lineId.isNotEmpty) {
      whereClause['line_id'] = {'_eq': lineId};
    }

    const String query = '''
      query GetCashOutHistory(\$where: cashouts_bool_exp!) {
        cashouts(where: \$where, order_by: {created_at: desc}) {
          id
          line_id
          amount
          date
          name
          comments
          is_active
          created_at
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'where': whereClause},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final List data = result.data?['cashouts'] ?? [];
    return data.map((json) => _mapToCashOutModel(json)).toList();
  }

  @override
  Future<void> settleCashOut(String id) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    const String mutation = '''
      mutation SettleCashOut(\$id: uuid!, \$userId: uuid!) {
        update_cashouts(
          where: {id: {_eq: \$id}, user_id: {_eq: \$userId}},
          _set: {is_active: false}
        ) {
          affected_rows
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {'id': id, 'userId': userId},
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final affected = result.data?['update_cashouts']?['affected_rows'] ?? 0;
    if (affected == 0) throw const ServerException('CashOut not found or not authorized.');
  }

  CashOutModel _mapToCashOutModel(Map<String, dynamic> json) {
    return CashOutModel(
      id: json['id'] as String,
      lineId: json['line_id'] as String,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: DateTime.parse(json['date'] as String),
      name: json['name'] as String,
      comments: json['comments'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
