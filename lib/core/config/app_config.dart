/// Centralized app configuration.
/// When the Hasura server is ready, update [hasuraHttpUrl] and [hasuraWsUrl].
/// These can later be loaded from a .env file using flutter_dotenv.
class AppConfig {
  AppConfig._();

  // ─── Hasura ───────────────────────────────────────────────────────────────
  /// HTTP endpoint for GraphQL queries & mutations
  static const String hasuraHttpUrl =
      'https://api.vasool.app/v1/graphql'; // Update when server is ready

  /// WebSocket endpoint for GraphQL subscriptions
  static const String hasuraWsUrl =
      'wss://api.vasool.app/v1/graphql'; // Update when server is ready

  // ─── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'Sri Vinayaga Finance';
  static const String appVersion = '1.0.0';

  // ─── Storage Keys ─────────────────────────────────────────────────────────
  static const String kAuthToken = 'auth_token';
  static const String kRefreshToken = 'refresh_token';
  static const String kUsername = 'username';
  static const String kUserId = 'user_id';
  static const String kUserRole = 'user_role';
  static const String kTheme = 'theme';
  static const String kIsLoggedIn = 'is_logged_in';
}
