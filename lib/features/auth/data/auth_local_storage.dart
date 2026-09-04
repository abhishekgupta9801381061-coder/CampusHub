import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user.dart';

class AuthLocalStorage {
  final FlutterSecureStorage _secureStorage;
  static const _tokenKey = 'campushub_session_token';
  static const _cachedUserKey = 'campushub_cached_user';

  AuthLocalStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<void> saveCachedUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
  }

  Future<User?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_cachedUserKey);
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearAll() async {
    await deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedUserKey);
  }
}
