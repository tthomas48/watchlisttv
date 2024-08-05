import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const ACCESS_TOKEN_KEY = "accessToken";
  static const REFRESH_TOKEN_KEY = "refreshToken";
  // Create storage
  final _storage = const FlutterSecureStorage();

  // Write value
  Future<void> setAccessToken(String accessToken) async {
    await _storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
  }

  Future<void> setRefreshToken(String refreshToken) async {
    await _storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
  }

  // Read value
  Future<String?> getAccessToken() async {
    return await _storage.read(key: ACCESS_TOKEN_KEY);
  }

  // Delete value
  Future<void> unsetAccessToken() async {
    await _storage.delete(key: ACCESS_TOKEN_KEY);
  }

  Future<void> unsetRefreshToken() async {
    await _storage.delete(key: REFRESH_TOKEN_KEY);
  }
}