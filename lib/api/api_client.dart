import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/auth_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;
  ApiException(this.statusCode, this.message, {this.details});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final http.Client _client;
  final String baseUrl;
  final AuthStorage _auth;

  ApiClient({http.Client? client, String? baseUrl, AuthStorage? auth})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _auth = auth ?? AuthStorage();

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await _auth.readToken();
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Spécial multipart (ne pas fixer Content-Type, laisser http le faire)
  Future<Map<String, String>> multipartHeaders() async {
    final token = await _auth.readToken();
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    final q = query.map((k, v) => MapEntry(k, v?.toString()));
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...q..removeWhere((key, value) => value == null),
    });
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _client.get(_uri(path, query), headers: await _headers());
    return _handle(res);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await _client.post(_uri(path), headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await _client.put(_uri(path), headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final res = await _client.patch(_uri(path), headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  Future<void> delete(String path) async {
    final res = await _client.delete(_uri(path), headers: await _headers(json: false));
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    _handle(res);
  }

  Map<String, dynamic> _handle(http.Response res) {
    final isJson = res.headers['content-type']?.contains('application/json') ?? false;
    final decoded = isJson && res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    }
    final msg = decoded is Map<String, dynamic>
        ? (decoded['message']?.toString() ?? 'Erreur API')
        : 'Erreur API';
    throw ApiException(res.statusCode, msg, details: decoded is Map<String, dynamic> ? decoded : null);
  }
}