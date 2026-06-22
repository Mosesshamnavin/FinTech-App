/// Thrown when the remote data source returns an error
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred.']);
}

/// Thrown when authentication fails (wrong credentials)
class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Invalid credentials.']);
}

/// Thrown when local cache/storage fails
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred.']);
}

/// Thrown when there is no internet connectivity
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection.']);
}
