import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/storage_service.dart';
import '../models/collection_model.dart';
import '../models/reminder_model.dart';
import 'collection_remote_datasource.dart';

class HasuraCollectionRemoteDataSourceImpl implements CollectionRemoteDataSource {
  final GraphQLClient client;
  final StorageService storageService;

  HasuraCollectionRemoteDataSourceImpl({required this.client, required this.storageService});

  String _formatDateForHasura(String dateStr) {
    // Expects "dd/MM/yyyy"
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final year = parts[2];
        final month = parts[1];
        final day = parts[0];
        // Ensure padded
        return year + "-" + month + "-" + day + "T00:00:00.000Z";
      }
    } catch (_) {}
    return dateStr;
  }

  String _formatDateFromHasura(String timestampStr) {
    try {
      final dt = DateTime.parse(timestampStr);
      return dt.day.toString().padLeft(2, '0') + '/' + dt.month.toString().padLeft(2, '0') + '/' + dt.year.toString();
    } catch (_) {}
    return timestampStr;
  }

  @override
  Future<List<CollectionModel>> getCollectionsByDate(String date) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    const String query = """
      query getCollectionsByDate(\$date: timestamp!, \$userId: uuid!) {
        collections(where: {date: {_eq: \$date}, user_id: {_eq: \$userId}}) {
          id
          customer_id
          amount
          date
          notes
          status
        }
      }
    """;

    final hasuraDate = _formatDateForHasura(date);

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {'date': hasuraDate, 'userId': userId},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final List data = result.data?['collections'] ?? [];
    return data.map((json) {
      return CollectionModel(
        id: json['id'],
        customerId: json['customer_id'],
        amount: (json['amount'] as num).toDouble(),
        date: _formatDateFromHasura(json['date']),
        notes: json['notes'],
        status: json['status'],
      );
    }).toList();
  }

  @override
  Future<CollectionModel> addCollection({
    required String customerId,
    required double amount,
    required String date,
    String? notes,
    required String status,
  }) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    const String mutation = """
      mutation addCollection(
        \$customer_id: uuid!,
        \$amount: numeric!,
        \$date: timestamp!,
        \$notes: String,
        \$status: String!,
        \$user_id: uuid!
      ) {
        insert_collections_one(object: {
          customer_id: \$customer_id,
          amount: \$amount,
          date: \$date,
          notes: \$notes,
          status: \$status,
          user_id: \$user_id
        }) {
          id
          customer_id
          amount
          date
          notes
          status
        }
      }
    """;

    final hasuraDate = _formatDateForHasura(date);

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'customer_id': customerId,
        'amount': amount,
        'date': hasuraDate,
        'notes': notes,
        'status': status,
        'user_id': userId,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final data = result.data?['insert_collections_one'];
    if (data == null) {
      throw ServerException("Failed to insert collection record.");
    }

    return CollectionModel(
      id: data['id'],
      customerId: data['customer_id'],
      amount: (data['amount'] as num).toDouble(),
      date: _formatDateFromHasura(data['date']),
      notes: data['notes'],
      status: data['status'],
    );
  }

  @override
  Future<void> addReminder(String date, String text) async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    const String mutation = """
      mutation addReminder(
        \$date: timestamp!,
        \$text: String!,
        \$user_id: uuid!
      ) {
        insert_reminders_one(object: {
          date: \$date,
          text: \$text,
          user_id: \$user_id
        }) {
          id
        }
      }
    """;

    final hasuraDate = _formatDateForHasura(date);

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'date': hasuraDate,
        'text': text,
        'user_id': userId,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }
  }

  @override
  Future<List<ReminderModel>> getReminders() async {
    final userId = await storageService.getUserId();
    if (userId == null) throw const ServerException('User not authenticated');

    const String query = """
      query getReminders(\$userId: uuid!) {
        reminders(where: {user_id: {_eq: \$userId}}, order_by: {date: asc}) {
          id
          date
          text
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {'userId': userId},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final List data = result.data?['reminders'] ?? [];
    return data.map((json) {
      return ReminderModel(
        id: json['id'],
        date: _formatDateFromHasura(json['date']),
        text: json['text'],
      );
    }).toList();
  }
}
