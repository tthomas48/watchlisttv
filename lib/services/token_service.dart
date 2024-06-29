import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const ACCESS_TOKEN_KEY = "accessToken";
  // Create storage
  final _storage = const FlutterSecureStorage();

  // Write value
  Future<void> setAccessToken(String accessToken) async {
    await _storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
  }

  // Read value
  Future<String?> getAccessToken() async {
    return await _storage.read(key: ACCESS_TOKEN_KEY);
  }

  // Delete value
  Future<void> unsetAccessToken() async {
    await _storage.delete(key: ACCESS_TOKEN_KEY);
  }
}