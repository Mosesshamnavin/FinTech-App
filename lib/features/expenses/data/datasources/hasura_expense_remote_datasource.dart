import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/expense_entity.dart';

import 'expense_remote_datasource.dart';

class HasuraExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final GraphQLClient client;

  HasuraExpenseRemoteDataSourceImpl({required this.client});

  Future<ExpenseEntity> addExpense(ExpenseEntity expense) async {
    final bool isInv = expense.isInvestment;
    
    // Mutation for Expenses
    const String mutationExpense = r'''
      mutation InsertExpense($amount: numeric!, $comments: String, $date: timestamp!, $isOnline: Boolean!, $lineId: uuid, $typeId: uuid!) {
        insert_expenses_one(object: {
          amount: $amount,
          comments: $comments,
          date: $date,
          is_online: $isOnline,
          line_id: $lineId,
          type_id: $typeId
        }) {
          id
        }
      }
    ''';

    // Mutation for Investments
    const String mutationInvestment = r'''
      mutation InsertInvestment($amount: numeric!, $comments: String, $date: timestamp!, $isOnline: Boolean!, $lineId: uuid, $typeId: uuid!) {
        insert_investments_one(object: {
          amount: $amount,
          comments: $comments,
          date: $date,
          is_online: $isOnline,
          line_id: $lineId,
          type_id: $typeId
        }) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(isInv ? mutationInvestment : mutationExpense),
        variables: {
          'amount': expense.amount,
          'comments': expense.description,
          'date': expense.date.toIso8601String(),
          'isOnline': expense.isOnline,
          'lineId': (expense.lineId != null && expense.lineId != 'All') ? expense.lineId : null,
          'typeId': expense.category, 
        },
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final id = result.data![isInv ? 'insert_investments_one' : 'insert_expenses_one']['id'];
    return ExpenseEntity(
      id: id,
      amount: expense.amount,
      category: expense.category,
      description: expense.description,
      date: expense.date,
      isInvestment: expense.isInvestment,
      isOnline: expense.isOnline,
      lineId: expense.lineId,
    );
  }

  Future<List<ExpenseEntity>> getExpenses({
    required DateTime from,
    required DateTime to,
    required bool isInvestment,
    String? lineId,
  }) async {
    final tableName = isInvestment ? 'investments' : 'expenses';
    
    final Map<String, dynamic> variables = {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    };
    
    String whereClause = 'date: {_gte: \$from, _lte: \$to}';
    if (lineId != null && lineId != 'All') {
      whereClause += ', line_id: {_eq: \$lineId}';
      variables['lineId'] = lineId;
    }

    final dynamicQuery = '''
      query Get${isInvestment ? 'Investments' : 'Expenses'}(\$from: timestamp!, \$to: timestamp!${lineId != null && lineId != 'All' ? ', \$lineId: uuid' : ''}) {
        $tableName(where: {$whereClause}, order_by: {date: desc}) {
          id
          amount
          comments
          date
          is_online
          line_id
          type_id
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(dynamicQuery),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final List data = result.data![tableName];
    return data.map((e) => ExpenseEntity(
      id: e['id'],
      amount: double.tryParse(e['amount']?.toString() ?? '0') ?? 0.0,
      category: e['type_id'] ?? 'Other', 
      description: e['comments'] ?? '',
      date: DateTime.parse(e['date']),
      isInvestment: isInvestment,
      isOnline: e['is_online'] == true,
      lineId: e['line_id'],
    )).toList();
  }
}
