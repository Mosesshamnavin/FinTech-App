import '../../../../core/error/exceptions.dart';
import '../../../../core/services/storage_service.dart';
import '../models/user_model.dart';

/// Handles reading/writing user data from local storage.
abstract class AuthLocalDataSource {
  /// Get the cached user from SharedPreferences. Returns null if not logged in.
  Future<UserModel?> getCachedUser();

  /// Cache user data to SharedPreferences.
  Future<void> cacheUser(UserModel user);

  /// Clear all cached auth data (on logout).
  Future<void> clearCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService storageService;

  AuthLocalDataSourceImpl(this.storageService);

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      if (!storageService.isLoggedIn()) return null;

      final token = storageService.getAuthToken();
      final username = storageService.getUsername();
      final userId = storageService.getUserId();
      final role = storageService.getUserRole();

      if (username == null || userId == null) return null;

      return UserModel(
        id: userId,
        username: username,
        email: '',
        role: role ?? 'agent',
        token: token,
      );
    } catch (_) {
      throw const CacheException('Failed to retrieve cached user.');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await storageService.saveUserId(user.id);
      await storageService.saveUsername(user.username);
      await storageService.saveUserRole(user.role);
      if (user.token != null) {
        await storageService.saveAuthToken(user.token!);
      }
      await storageService.setLoggedIn(true);
    } catch (_) {
      throw const CacheException('Failed to cache user.');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    await storageService.clearAuth();
  }
}
