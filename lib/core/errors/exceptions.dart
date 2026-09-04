class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException([this.message = 'Server Error', this.statusCode]);

  @override
  String toString() => 'ServerException: $message ($statusCode)';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);

  @override
  String toString() => 'CacheException: $message';
}

class RateLimitException implements Exception {
  final String message;
  const RateLimitException(this.message);

  @override
  String toString() => 'RateLimitException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
