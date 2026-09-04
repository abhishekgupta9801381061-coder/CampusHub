import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  SecurityUtils._();

  static const String _saltPrefix = 'campushub_salt_privacy_v1_';

  /// Hashes a sensitive string (e.g. security answer or password) with salt.
  /// Normalized to lower case and trimmed for security answers so user casing does not lock them out.
  static String hashSensitiveString(String rawValue) {
    final normalized = rawValue.trim().toLowerCase();
    final bytes = utf8.encode('$_saltPrefix$normalized');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies a plain text answer against a stored hash
  static bool verifyHash(String rawValue, String storedHash) {
    final computedHash = hashSensitiveString(rawValue);
    return computedHash == storedHash;
  }
}

class AppLogger {
  AppLogger._();

  static void info(String message) {
    final sanitized = _sanitize(message);
    // ignore: avoid_print
    print('[CampusHub INFO] $sanitized');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    final sanitized = _sanitize(message);
    // ignore: avoid_print
    print('[CampusHub ERROR] $sanitized: $error');
  }

  static String _sanitize(String input) {
    // Redact password, securityAnswer, tokens from any log
    final sensitivePatterns = [
      RegExp(r'(password[:=]\s*)[^\s,]+', caseSensitive: false),
      RegExp(r'(securityAnswer[:=]\s*)[^\s,]+', caseSensitive: false),
      RegExp(r'(token[:=]\s*)[^\s,]+', caseSensitive: false),
      RegExp(r'(secret[:=]\s*)[^\s,]+', caseSensitive: false),
    ];
    String result = input;
    for (final pattern in sensitivePatterns) {
      result = result.replaceAllMapped(pattern, (match) => '${match.group(1)}[REDACTED]');
    }
    return result;
  }
}
