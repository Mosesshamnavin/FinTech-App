import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Abstract contract for the remote auth data source.
/// Currently implemented with mock data.
/// When Hasura is ready, replace [MockAuthRemoteDataSourceImpl] with
/// [HasuraAuthRemoteDataSourceImpl] in the injection container — nothing else changes.
abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
  Future<UserModel> register({
    required String name,
    required String username,
    required String password,
    required String email,
    required String mobile,
  });
  Future<void> sendOtp({required String username});
  Future<void> resetPassword({required String otp, required String newPassword});
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK IMPLEMENTATION
// Replace this with HasuraAuthRemoteDataSourceImpl when server is ready.
// ─────────────────────────────────────────────────────────────────────────────

/// Hardcoded demo credentials for development & testing without a server.
/// Demo accounts:
///   admin / admin123  → role: admin
///   agent / agent123  → role: agent
class HasuraAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GraphQLClient client;

  HasuraAuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    const String query = r'''
      query Login($username: String!, $password: String!) {
        users(where: {username: {_eq: $username}, password: {_eq: $password}}) {
          id
          username
          name
          email
          role
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {
          'username': username,
          'password': password,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final List usersData = result.data?['users'] ?? [];
    if (usersData.isEmpty) {
      throw const AuthException('Invalid username or password.');
    }

    final user = usersData.first;
    return UserModel(
      id: user['id'].toString(),
      username: user['username'].toString(),
      name: user['name']?.toString() ?? user['username'].toString(),
      email: user['email'].toString(),
      role: user['role'].toString(),
      token: 'mock-jwt-token', // You can replace this with a real JWT if you setup an Auth server later
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String username,
    required String password,
    required String email,
    required String mobile,
  }) async {
    // First, check if user exists
    const String checkQuery = r'''
      query CheckUsername($username: String!) {
        users(where: {username: {_eq: $username}}) {
          id
        }
      }
    ''';

    final checkResult = await client.query(
      QueryOptions(
        document: gql(checkQuery),
        variables: {'username': username},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (checkResult.hasException) {
      throw ServerException(checkResult.exception.toString());
    }

    final List existingUsers = checkResult.data?['users'] ?? [];
    if (existingUsers.isNotEmpty) {
      throw const ServerException('Username already taken. Please choose another.');
    }

    // If username is unique, insert user
    const String mutation = r'''
      mutation InsertUser($name: String!, $username: String!, $password: String!, $email: String!, $mobile: String!) {
        insert_users_one(object: {
          name: $name,
          username: $username,
          password: $password,
          email: $email,
          mobile: $mobile,
          role: "agent"
        }) {
          id
          role
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {
          'name': name,
          'username': username,
          'password': password,
          'email': email,
          'mobile': mobile,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    final insertData = result.data?['insert_users_one'];
    if (insertData == null) {
      throw const ServerException('Failed to create user. Please try again.');
    }

    return UserModel(
      id: insertData['id'].toString(),
      username: username,
      name: name,
      email: email,
      role: insertData['role'].toString(),
      token: 'mock-jwt-token',
    );
  }

  @override
  Future<void> sendOtp({required String username}) async {
    // Simulated OTP send
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> resetPassword({
    required String otp,
    required String newPassword,
  }) async {
    // Simulated password reset
    await Future.delayed(const Duration(milliseconds: 500));
    if (otp != '123456') {
      throw const AuthException('Invalid OTP. Please try again.');
    }
  }
}
