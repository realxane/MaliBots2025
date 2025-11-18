import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  final Map<String, dynamic>? details;
  ApiException(this.status, this.message, {this.details});
  @override
  String toString() => 'ApiException($status): $message';
}

class ApiHttp {
  final String baseUrl; // ex: 'http://10.0.2.2:8000/api'
  final http.Client _client;
  final FlutterSecureStorage _secure;
  final Duration timeout;

  ApiHttp(
    this.baseUrl, {
    http.Client? client,
    FlutterSecureStorage? secure,
    this.timeout = const Duration(seconds: 15),
  })  : _client = client ?? http.Client(),
        _secure = secure ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) => _secure.write(key: 'token', value: token);
  Future<void> clearToken() => _secure.delete(key: 'token');
  Future<String?> get token async => _secure.read(key: 'token');

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final uri = Uri.parse('$cleanBase$path');
    if (query == null) return uri;
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      for (final e in query.entries) e.key: e.value?.toString() ?? '',
    });
  }

  Future<Map<String, String>> _headers({bool json = true}) async {
    final h = <String, String>{'Accept': 'application/json'};
    if (json) h['Content-Type'] = 'application/json';
    final t = await token;
    if (t != null) h['Authorization'] = 'Bearer $t';
    return h;
  }

  dynamic _decode(String body) => body.isEmpty ? null : jsonDecode(body);

  Never _throw(http.Response r) {
    Map<String, dynamic>? details;
    String msg = 'Erreur API';
    try {
      if (r.body.isNotEmpty) {
        final parsed = jsonDecode(r.body);
        if (parsed is Map) {
          details = parsed.cast<String, dynamic>();
          msg = (parsed['message'] ?? parsed['error'] ?? msg).toString();
        }
      }
    } catch (_) {}
    throw ApiException(r.statusCode, msg, details: details);
  }

  dynamic _handle(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.statusCode == 204) return null;
      return _decode(r.body);
    }
    if (r.statusCode == 401) {
      clearToken(); // token invalide -> déconnexion locale
    }
    _throw(r);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _client.get(_uri(path, query), headers: await _headers()).timeout(timeout);
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? data}) async {
    final res = await _client.post(_uri(path), headers: await _headers(), body: data == null ? null : jsonEncode(data)).timeout(timeout);
    return _handle(res);
  }

  Future<dynamic> put(String path, {Object? data}) async {
    final res = await _client.put(_uri(path), headers: await _headers(), body: data == null ? null : jsonEncode(data)).timeout(timeout);
    return _handle(res);
  }

  Future<dynamic> patch(String path, {Object? data}) async {
    final res = await _client.patch(_uri(path), headers: await _headers(), body: data == null ? null : jsonEncode(data)).timeout(timeout);
    return _handle(res);
  }

  Future<dynamic> delete(String path, {Object? data}) async {
    final res = await _client.delete(_uri(path), headers: await _headers(), body: data == null ? null : jsonEncode(data)).timeout(timeout);
    return _handle(res);
  }

  Uri uri(String path, [Map<String, dynamic>? query]) => _uri(path, query);
}