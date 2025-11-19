import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _key = 'auth_token';
  final FlutterSecureStorage _s = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _s.write(key: _key, value: token);
  Future<String?> readToken() => _s.read(key: _key);
  Future<void> clear() => _s.delete(key: _key);
}