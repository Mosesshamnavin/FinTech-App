import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/settings_entities.dart';

class SettingsRemoteDataSource {
  final GraphQLClient client;

  SettingsRemoteDataSource({required this.client});

  Future<LineEntity> addLine(LineEntity line) async {
    const String mutation = r'''
      mutation InsertLine($name: String!, $type: String!, $interest: numeric!, $bill: numeric!, $install: Int!, $bad: Int!, $close: Boolean!, $penalty: Boolean!, $keep: Boolean!) {
        insert_lines_one(object: {
          name: $name,
          type: $type,
          interest_per_hundred: $interest,
          bill_amount_per_hundred: $bill,
          no_of_install: $install,
          bad_loan_days: $bad,
          close_loan_manually: $close,
          enable_penalty: $penalty,
          keep_paid_customer: $keep
        }) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'name': line.name,
          'type': line.type,
          'interest': line.interestPerHundred,
          'bill': line.billAmountPerHundred,
          'install': line.noOfInstall,
          'bad': line.badLoanDays,
          'close': line.closeLoanManually,
          'penalty': line.enablePenalty,
          'keep': line.keepPaidCustomer,
        },
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final id = result.data!['insert_lines_one']['id'];
    return LineEntity(
      id: id,
      name: line.name,
      type: line.type,
      interestPerHundred: line.interestPerHundred,
      billAmountPerHundred: line.billAmountPerHundred,
      noOfInstall: line.noOfInstall,
      badLoanDays: line.badLoanDays,
      closeLoanManually: line.closeLoanManually,
      enablePenalty: line.enablePenalty,
      keepPaidCustomer: line.keepPaidCustomer,
    );
  }

  Future<List<LineEntity>> getLines() async {
    const String query = r'''
      query GetLines {
        lines {
          id
          name
          type
          interest_per_hundred
          bill_amount_per_hundred
          no_of_install
          bad_loan_days
          close_loan_manually
          enable_penalty
          keep_paid_customer
        }
      }
    ''';

    final result = await client.query(QueryOptions(document: gql(query), fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());

    final List linesData = result.data!['lines'];
    return linesData.map((e) => LineEntity(
      id: e['id']?.toString() ?? '',
      name: e['name']?.toString() ?? '',
      type: e['type']?.toString() ?? '',
      interestPerHundred: double.tryParse(e['interest_per_hundred']?.toString() ?? '0') ?? 0.0,
      billAmountPerHundred: double.tryParse(e['bill_amount_per_hundred']?.toString() ?? '0') ?? 0.0,
      noOfInstall: int.tryParse(e['no_of_install']?.toString() ?? '0') ?? 0,
      badLoanDays: int.tryParse(e['bad_loan_days']?.toString() ?? '0') ?? 0,
      closeLoanManually: e['close_loan_manually'] == true,
      enablePenalty: e['enable_penalty'] == true,
      keepPaidCustomer: e['keep_paid_customer'] == true,
    )).toList();
  }

  Future<AreaEntity> addArea(AreaEntity area) async {
    const String mutation = r'''
      mutation InsertArea($name: String!, $lineId: uuid!) {
        insert_areas_one(object: {name: $name, line_id: $lineId}) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'name': area.name,
          'lineId': area.lineId,
        },
      ),
    );

    if (result.hasException) throw ServerException(result.exception.toString());

    final id = result.data!['insert_areas_one']['id'];
    return AreaEntity(id: id, name: area.name, lineId: area.lineId);
  }

  Future<List<AreaEntity>> getAreas() async {
    const String query = r'''
      query GetAreas {
        areas {
          id
          name
          line_id
        }
      }
    ''';

    final result = await client.query(QueryOptions(document: gql(query), fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());

    final List areasData = result.data!['areas'];
    return areasData.map((e) => AreaEntity(
      id: e['id']?.toString() ?? '',
      name: e['name']?.toString() ?? '',
      lineId: e['line_id']?.toString() ?? '',
    )).toList();
  }

  Future<ExpenseTypeEntity> addExpenseType(ExpenseTypeEntity expenseType) async {
    const String mutation = r'''
      mutation InsertExpenseType($name: String!) {
        insert_expense_types_one(object: {name: $name}) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(document: gql(mutation), variables: {'name': expenseType.name}),
    );

    if (result.hasException) throw ServerException(result.exception.toString());

    final id = result.data!['insert_expense_types_one']['id'];
    return ExpenseTypeEntity(id: id, name: expenseType.name);
  }

  Future<List<ExpenseTypeEntity>> getExpenseTypes() async {
    const String query = r'''
      query GetExpenseTypes {
        expense_types {
          id
          name
          is_active
        }
      }
    ''';

    final result = await client.query(QueryOptions(document: gql(query), fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());

    final List data = result.data!['expense_types'];
    return data.map((e) => ExpenseTypeEntity(
      id: e['id']?.toString() ?? '',
      name: e['name']?.toString() ?? '',
      isActive: e['is_active'] == true,
    )).toList();
  }

  Future<InvestmentTypeEntity> addInvestmentType(InvestmentTypeEntity investmentType) async {
    const String mutation = r'''
      mutation InsertInvestmentType($name: String!) {
        insert_investment_types_one(object: {name: $name}) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(document: gql(mutation), variables: {'name': investmentType.name}),
    );

    if (result.hasException) throw ServerException(result.exception.toString());

    final id = result.data!['insert_investment_types_one']['id'];
    return InvestmentTypeEntity(id: id, name: investmentType.name);
  }

  Future<List<InvestmentTypeEntity>> getInvestmentTypes() async {
    const String query = r'''
      query GetInvestmentTypes {
        investment_types {
          id
          name
          is_active
        }
      }
    ''';

    final result = await client.query(QueryOptions(document: gql(query), fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());

    final List data = result.data!['investment_types'];
    return data.map((e) => InvestmentTypeEntity(
      id: e['id']?.toString() ?? '',
      name: e['name']?.toString() ?? '',
      isActive: e['is_active'] == true,
    )).toList();
  }
}
