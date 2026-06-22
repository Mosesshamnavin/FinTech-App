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
class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const _mockDelay = Duration(milliseconds: 800); // simulate network

  static const _mockUsers = [
    {
      'id': 'mock-user-001',
      'username': 'admin',
      'password': 'admin',
      'email': 'admin@vasool.app',
      'role': 'admin',
      'token': 'mock-jwt-admin-token',
    },
    {
      'id': 'mock-user-002',
      'username': 'agent',
      'password': 'agent',
      'email': 'agent@vasool.app',
      'role': 'agent',
      'token': 'mock-jwt-agent-token',
    },
  ];

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(_mockDelay);

    final user = _mockUsers.where(
      (u) => u['username'] == username && u['password'] == password,
    );

    if (user.isEmpty) {
      throw const AuthException('Invalid username or password.');
    }

    final u = user.first;
    return UserModel(
      id: u['id']!,
      username: u['username']!,
      email: u['email']!,
      role: u['role']!,
      token: u['token']!,
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
    await Future.delayed(_mockDelay);

    // Check if username already exists
    final exists = _mockUsers.any((u) => u['username'] == username);
    if (exists) {
      throw const ServerException('Username already taken. Please choose another.');
    }

    // Return newly created mock user
    return UserModel(
      id: 'mock-new-user-${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: email,
      role: 'agent',
      token: 'mock-jwt-new-token',
    );
  }

  @override
  Future<void> sendOtp({required String username}) async {
    await Future.delayed(_mockDelay);
    // Mock: always succeeds for any username
  }

  @override
  Future<void> resetPassword({
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(_mockDelay);
    if (otp != '123456') {
      throw const AuthException('Invalid OTP. Please try again.');
    }
    // Mock: OTP 123456 always works
  }
}
