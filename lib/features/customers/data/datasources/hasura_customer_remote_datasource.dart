import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../models/customer_model.dart';
import 'customer_remote_datasource.dart';

class HasuraCustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final GraphQLClient client;

  HasuraCustomerRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CustomerModel>> getCustomers({String? lineId, String? areaId}) async {
    Map<String, dynamic> whereClause = {};
    if (lineId != null && lineId.isNotEmpty) {
      whereClause['line_id'] = {'_eq': lineId};
    }
    if (areaId != null && areaId.isNotEmpty) {
      whereClause['area_id'] = {'_eq': areaId};
    }

    const String dynamicQuery = '''
      query GetCustomers(\$where: customers_bool_exp!) {
        customers(where: \$where, order_by: { created_at: desc }) {
          id
          name
          phone
          line_id
          area_id
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(dynamicQuery),
      variables: {
        'where': whereClause,
      },
      fetchPolicy: FetchPolicy.networkOnly, 
    );

    try {
      final QueryResult result = await client.query(options);

      if (result.hasException) {
        throw ServerException(result.exception.toString());
      }

      final List<dynamic> customersData = result.data?['customers'] ?? [];
      
      return customersData.map((json) => CustomerModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        address: '', // Default since it doesn't exist in DB
        lineId: json['line_id'] as String,
        areaId: json['area_id'] as String,
        isActive: true, // Default
      )).toList();
      
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CustomerModel> addCustomer({
    required String name,
    required String phone,
    required String address, // Keeping parameter so UI doesn't break, but ignoring it
    required String lineId,
    required String areaId,
  }) async {
    const String mutation = '''
      mutation InsertCustomer(\$object: customers_insert_input!) {
        insert_customers_one(object: \$object) {
          id
          name
          phone
          line_id
          area_id
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'object': {
          'name': name,
          'phone': phone,
          'line_id': lineId,
          'area_id': areaId,
        }
      },
    );

    try {
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        if (result.exception.toString().contains('customers_phone_key')) {
           throw const ServerException('A customer with this phone number already exists.');
        }
        throw ServerException(result.exception.toString());
      }

      final data = result.data?['insert_customers_one'];
      if (data == null) throw const ServerException('Failed to add customer.');

      return CustomerModel(
        id: data['id'] as String,
        name: data['name'] as String,
        phone: data['phone'] as String,
        address: '', // default
        lineId: data['line_id'] as String,
        areaId: data['area_id'] as String,
        isActive: true, // default
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
