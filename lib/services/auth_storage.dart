import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _keyToken = 'auth_token';
  static const _keyRole  = 'auth_role';

  final FlutterSecureStorage _s = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _s.write(key: _keyToken, value: token);
  Future<String?> readToken() => _s.read(key: _keyToken);

  Future<void> saveRole(String? role) async {
    if (role == null) return;
    await _s.write(key: _keyRole, value: role);
  }
  Future<String?> readRole() => _s.read(key: _keyRole);

  Future<void> clear() async {
    await _s.delete(key: _keyToken);
    await _s.delete(key: _keyRole);
  }
}