import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/settings_entities.dart';

class SettingsRemoteDataSource {
  final GraphQLClient client;

  SettingsRemoteDataSource({required this.client});

  // ─── Line Type CRUD ─────────────────────────────────────────────────────

  Future<LineTypeEntity> addLineType(LineTypeEntity lineType) async {
    const String mutation = r'''
      mutation InsertLineType($name: String!) {
        insert_line_types_one(object: {name: $name}) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(document: gql(mutation), variables: {'name': lineType.name}),
    );

    if (result.hasException) throw ServerException(result.exception.toString());

    final id = result.data!['insert_line_types_one']['id'];
    return LineTypeEntity(id: id, name: lineType.name);
  }

  Future<List<LineTypeEntity>> getLineTypes() async {
    const String query = r'''
      query GetLineTypes {
        line_types {
          id
          name
          is_active
        }
      }
    ''';

    final result = await client.query(QueryOptions(document: gql(query), fetchPolicy: FetchPolicy.networkOnly));
    if (result.hasException) throw ServerException(result.exception.toString());

    final List data = result.data!['line_types'];
    return data.map((e) => LineTypeEntity(
      id: e['id']?.toString() ?? '',
      name: e['name']?.toString() ?? '',
      isActive: e['is_active'] == true,
    )).toList();
  }

  Future<void> updateLineType(LineTypeEntity lineType) async {
    const String mutation = r'''
      mutation UpdateLineType($id: uuid!, $name: String!, $isActive: Boolean!) {
        update_line_types_by_pk(pk_columns: {id: $id}, _set: {name: $name, is_active: $isActive}) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {'id': lineType.id, 'name': lineType.name, 'isActive': lineType.isActive},
      ),
    );

    if (result.hasException) throw ServerException(result.exception.toString());
  }

  Future<void> deleteLineType(String id) async {
    const String mutation = r'''
      mutation DeleteLineType($id: uuid!) {
        delete_line_types_by_pk(id: $id) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(document: gql(mutation), variables: {'id': id}),
    );

    if (result.hasException) throw ServerException(result.exception.toString());
  }

  // ─── Line CRUD ──────────────────────────────────────────────────────────

  Future<LineEntity> addLine(LineEntity line) async {
    const String mutation = r'''
      mutation InsertLine($name: String!, $lineTypeId: uuid!, $interest: numeric!, $bill: numeric!, $install: Int!, $bad: Int!, $close: Boolean!, $penalty: Boolean!, $keep: Boolean!) {
        insert_lines_one(object: {
          name: $name,
          line_type_id: $lineTypeId,
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
          'lineTypeId': line.lineTypeId,
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
      lineTypeId: line.lineTypeId,
      lineTypeName: line.lineTypeName,
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
          line_type_id
          line_type {
            name
          }
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
      lineTypeId: e['line_type_id']?.toString() ?? '',
      lineTypeName: e['line_type']?['name']?.toString() ?? '',
      interestPerHundred: double.tryParse(e['interest_per_hundred']?.toString() ?? '0') ?? 0.0,
      billAmountPerHundred: double.tryParse(e['bill_amount_per_hundred']?.toString() ?? '0') ?? 0.0,
      noOfInstall: int.tryParse(e['no_of_install']?.toString() ?? '0') ?? 0,
      badLoanDays: int.tryParse(e['bad_loan_days']?.toString() ?? '0') ?? 0,
      closeLoanManually: e['close_loan_manually'] == true,
      enablePenalty: e['enable_penalty'] == true,
      keepPaidCustomer: e['keep_paid_customer'] == true,
    )).toList();
  }

  Future<void> updateLine(LineEntity line) async {
    const String mutation = r'''
      mutation UpdateLine($id: uuid!, $name: String!, $lineTypeId: uuid!, $interest: numeric!, $bill: numeric!, $install: Int!, $bad: Int!, $close: Boolean!, $penalty: Boolean!, $keep: Boolean!) {
        update_lines_by_pk(
          pk_columns: {id: $id},
          _set: {
            name: $name,
            line_type_id: $lineTypeId,
            interest_per_hundred: $interest,
            bill_amount_per_hundred: $bill,
            no_of_install: $install,
            bad_loan_days: $bad,
            close_loan_manually: $close,
            enable_penalty: $penalty,
            keep_paid_customer: $keep
          }
        ) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'id': line.id,
          'name': line.name,
          'lineTypeId': line.lineTypeId,
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

    if (result.hasException) throw ServerException(result.exception.toString());
  }

  Future<void> deleteLine(String id) async {
    const String mutation = r'''
      mutation DeleteLine($id: uuid!) {
        delete_lines_by_pk(id: $id) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(document: gql(mutation), variables: {'id': id}),
    );

    if (result.hasException) throw ServerException(result.exception.toString());
  }

  // ─── Area CRUD ──────────────────────────────────────────────────────────

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

  Future<void> updateArea(AreaEntity area) async {
    const String mutation = r'''
      mutation UpdateArea($id: uuid!, $name: String!, $lineId: uuid!) {
        update_areas_by_pk(pk_columns: {id: $id}, _set: {name: $name, line_id: $lineId}) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {'id': area.id, 'name': area.name, 'lineId': area.lineId},
      ),
    );

    if (result.hasException) throw ServerException(result.exception.toString());
  }

  Future<void> deleteArea(String id) async {
    const String mutation = r'''
      mutation DeleteArea($id: uuid!) {
        delete_areas_by_pk(id: $id) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(document: gql(mutation), variables: {'id': id}),
    );

    if (result.hasException) throw ServerException(result.exception.toString());
  }

  // ─── Expense Type CRUD ──────────────────────────────────────────────────

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

  Future<void> updateExpenseType(ExpenseTypeEntity expenseType) async {
    const String mutation = r'''
      mutation UpdateExpenseType($id: uuid!, $name: String!, $isActive: Boolean!) {
        update_expense_types_by_pk(pk_columns: {id: $id}, _set: {name: $name, is_active: $isActive}) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {'id': expenseType.id, 'name': expenseType.name, 'isActive': expenseType.isActive},
      ),
    );

    if (result.hasException) throw ServerException(result.exception.toString());
  }

  Future<void> deleteExpenseType(String id) async {
    const String mutation = r'''
      mutation DeleteExpenseType($id: uuid!) {
        delete_expense_types_by_pk(id: $id) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(document: gql(mutation), variables: {'id': id}),
    );

    if (result.hasException) throw ServerException(result.exception.toString());
  }

  // ─── Investment Type CRUD ───────────────────────────────────────────────

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

  Future<void> updateInvestmentType(InvestmentTypeEntity investmentType) async {
    const String mutation = r'''
      mutation UpdateInvestmentType($id: uuid!, $name: String!, $isActive: Boolean!) {
        update_investment_types_by_pk(pk_columns: {id: $id}, _set: {name: $name, is_active: $isActive}) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {'id': investmentType.id, 'name': investmentType.name, 'isActive': investmentType.isActive},
      ),
    );

    if (result.hasException) throw ServerException(result.exception.toString());
  }

  Future<void> deleteInvestmentType(String id) async {
    const String mutation = r'''
      mutation DeleteInvestmentType($id: uuid!) {
        delete_investment_types_by_pk(id: $id) {
          id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(document: gql(mutation), variables: {'id': id}),
    );

    if (result.hasException) throw ServerException(result.exception.toString());
  }
}
