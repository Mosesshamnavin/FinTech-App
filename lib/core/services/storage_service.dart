import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// A service wrapper around SharedPreferences for typed reads/writes.
/// Handles all app-level persistent storage (non-sensitive data).
/// For sensitive data (JWT tokens), use flutter_secure_storage when added.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(AppConfig.kAuthToken, token);
  }

  String? getAuthToken() => _prefs.getString(AppConfig.kAuthToken);

  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(AppConfig.kRefreshToken, token);
  }

  String? getRefreshToken() => _prefs.getString(AppConfig.kRefreshToken);

  Future<void> saveUsername(String username) async {
    await _prefs.setString(AppConfig.kUsername, username);
  }

  String? getUsername() => _prefs.getString(AppConfig.kUsername);

  Future<void> saveUserId(String userId) async {
    await _prefs.setString(AppConfig.kUserId, userId);
  }

  String? getUserId() => _prefs.getString(AppConfig.kUserId);

  Future<void> saveUserRole(String role) async {
    await _prefs.setString(AppConfig.kUserRole, role);
  }

  String? getUserRole() => _prefs.getString(AppConfig.kUserRole);

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(AppConfig.kIsLoggedIn, value);
  }

  bool isLoggedIn() => _prefs.getBool(AppConfig.kIsLoggedIn) ?? false;

  // ─── Theme ────────────────────────────────────────────────────────────────

  Future<void> saveTheme(String theme) async {
    await _prefs.setString(AppConfig.kTheme, theme);
  }

  String getTheme() => _prefs.getString(AppConfig.kTheme) ?? 'Blue';

  // ─── Clear ────────────────────────────────────────────────────────────────

  Future<void> clearAuth() async {
    await _prefs.remove(AppConfig.kAuthToken);
    await _prefs.remove(AppConfig.kRefreshToken);
    await _prefs.remove(AppConfig.kUsername);
    await _prefs.remove(AppConfig.kUserId);
    await _prefs.remove(AppConfig.kUserRole);
    await _prefs.setBool(AppConfig.kIsLoggedIn, false);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
