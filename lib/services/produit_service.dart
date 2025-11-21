import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:malibots_challenge_eni/services/auth_storage.dart';
import 'package:malibots_challenge_eni/models/product.dart';

// ====== MODELE TOP-LEVEL (pas de classe imbriquée) ======
class RegionRef {
  final String id;
  final String name;
  const RegionRef({required this.id, required this.name});

  factory RegionRef.fromJson(Map<String, dynamic> j) {
    final id = (j['id'] ?? j['uuid'] ?? j['code']).toString();
    final name = (j['nom'] ?? j['name'] ?? j['label'] ?? j['libelle'] ?? '').toString();
    return RegionRef(id: id, name: name);
  }
}

class ProduitService {
  final String baseUrl = "http://192.168.1.103:8000/api";
  final _storage = AuthStorage();

  Future<String?> currentToken() => _storage.readToken();
  Future<String?> currentRole() => _storage.readRole();

  Map<String, String> _authJsonHeaders(String token) {
    final t = token.trim();
    final auth = t.toLowerCase().startsWith('bearer ') ? t : 'Bearer $t';
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': auth,
    };
  }

  bool _isRemote(String p) => p.startsWith('http://') || p.startsWith('https://');

  Future<void> _debugAuth() async {
    final t = await currentToken();
    if (t == null) { debugPrint("Pas de token en storage"); return; }
    debugPrint("TOKEN=${t.substring(0, 12)}...");

    final me = await http.get(Uri.parse("$baseUrl/me"), headers: _authJsonHeaders(t));
    debugPrint("GET /me -> ${me.statusCode} ${me.body}");

    final vend = await http.get(Uri.parse("$baseUrl/vendeur/produits"), headers: _authJsonHeaders(t));
    debugPrint("GET /vendeur/produits -> ${vend.statusCode} ${vend.body}");
  }

  // ---- fetch des régions (utilise le modèle top-level) ----
  Future<List<RegionRef>> fetchRegions() async {
    final resp = await http.get(Uri.parse("$baseUrl/regions"), headers: {
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 20));

    if (resp.statusCode != 200) {
      throw Exception("Impossible de charger les régions (${resp.statusCode})");
    }
    final body = jsonDecode(resp.body);
    if (body is List) {
      return body.map((e) => RegionRef.fromJson(e as Map<String, dynamic>)).toList();
    }
    final data = (body is Map && body['data'] is List) ? body['data'] as List : const [];
    return data.map((e) => RegionRef.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<String>> _uploadImagesReturningUrls({
    required List<String> localPaths,
    required String token,
  }) async {
    if (localPaths.isEmpty) return const [];
    final isMany = localPaths.length > 1;
    final uri = Uri.parse("$baseUrl/uploads${isMany ? '/many' : ''}");
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = _authJsonHeaders(token)['Authorization']!
      ..headers['Accept'] = 'application/json';

    if (isMany) {
      for (final p in localPaths) {
        req.files.add(await http.MultipartFile.fromPath('files[]', p));
      }
    } else {
      req.files.add(await http.MultipartFile.fromPath('file', localPaths.first));
    }

    final streamed = await req.send().timeout(const Duration(seconds: 40));
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception("Échec de l’upload (${resp.statusCode}) ${resp.body}");
    }

    final body = resp.body.isEmpty ? {} : jsonDecode(resp.body);
    List<String> out = [];
    if (body is Map<String, dynamic>) {
      if (body['urls'] is List) {
        out = (body['urls'] as List).map((e) => e.toString()).toList();
      } else if (body['data'] is List) {
        out = (body['data'] as List)
            .map((e) => (e is Map && e['url'] != null) ? e['url'].toString() : null)
            .whereType<String>()
            .toList();
      } else if (body['url'] != null) {
        out = [body['url'].toString()];
      }
    }
    if (out.isEmpty) {
      throw Exception("Réponse upload inattendue: ${resp.body}");
    }
    return out;
  }

  Future<Produit> createFromUi({
    required String nom,
    required String description,
    required double prix,
    required String uiCategorie,
    required String regionId,
    required int stock,
    required List<String> imageLocalPathsOrUrls,
    String? couleur,
  }) async {
    final token = await currentToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception("Session expirée, reconnectez-vous.");
    }

    final role = await currentRole();
    if (role != null && role.toLowerCase() != 'vendeur') {
      throw Exception("Votre compte n’a pas le rôle vendeur.");
    }

    final remote = <String>[];
    final local = <String>[];
    for (final p in imageLocalPathsOrUrls) {
      (_isRemote(p) ? remote : local).add(p);
    }

    final uploaded = await _uploadImagesReturningUrls(localPaths: local, token: token);
    final allUrls = [...remote, ...uploaded];

    final payload = {
      "nom": nom,
      "description": description,
      "prix": prix,
      "categorie": uiCategorie,
      "regionId": regionId,
      "stock": stock,
      if (couleur != null) "couleur": couleur,
      "images": allUrls,
    };

    final url = Uri.parse("$baseUrl/vendeur/produits");
    final resp = await http
        .post(url, headers: _authJsonHeaders(token), body: jsonEncode(payload))
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode == 201) {
      final data = jsonDecode(resp.body);
      final map = data is Map<String, dynamic> ? data : {"data": data};
      return Produit.fromJson(map);
    } else if (resp.statusCode == 422) {
      final data = jsonDecode(resp.body);
      final errors = (data["errors"] as Map<String, dynamic>?)
              ?.entries
              .map((e) => "${e.key}: ${(e.value as List).join(', ')}")
              .join("\n") ??
          "Erreur de validation";
      throw Exception(errors);
    } else if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw Exception(_extractMessage(resp.body) ?? "Non autorisé. Vérifie le token et le rôle vendeur.");
    } else {
      throw Exception("Erreur ${resp.statusCode}: ${resp.body}");
    }
  }

  Future<Produit> updateFromUi({
    required String id,
    required String nom,
    required String description,
    required double prix,
    required String uiCategorie,
    required String regionId,
    required int stock,
    required List<String> imageLocalPathsOrUrls,
    String? couleur,
  }) async {
    final token = await currentToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception("Session expirée, reconnectez-vous.");
    }

    final role = await currentRole();
    if (role != null && role.toLowerCase() != 'vendeur') {
      throw Exception("Votre compte n’a pas le rôle vendeur.");
    }

    final remote = <String>[];
    final local = <String>[];
    for (final p in imageLocalPathsOrUrls) {
      (_isRemote(p) ? remote : local).add(p);
    }

    final uploaded = await _uploadImagesReturningUrls(localPaths: local, token: token);
    final allUrls = [...remote, ...uploaded];

    final payload = {
      "nom": nom,
      "description": description,
      "prix": prix,
      "categorie": uiCategorie,
      "regionId": regionId,
      "stock": stock,
      if (couleur != null) "couleur": couleur,
      "images": allUrls,
    };

    final url = Uri.parse("$baseUrl/vendeur/produits/$id");
    final resp = await http
        .put(url, headers: _authJsonHeaders(token), body: jsonEncode(payload))
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final map = data is Map<String, dynamic> ? data : {"data": data};
      return Produit.fromJson(map);
    } else if (resp.statusCode == 422) {
      final data = jsonDecode(resp.body);
      final errors = (data["errors"] as Map<String, dynamic>?)
              ?.entries
              .map((e) => "${e.key}: ${(e.value as List).join(', ')}")
              .join("\n") ??
          "Erreur de validation";
      throw Exception(errors);
    } else if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw Exception(_extractMessage(resp.body) ?? "Non autorisé. Vérifie le token et le rôle vendeur.");
    } else {
      throw Exception("Erreur ${resp.statusCode}: ${resp.body}");
    }
  }

  String? _extractMessage(String body) {
    try {
      final m = jsonDecode(body);
      if (m is Map && m['message'] != null) return m['message'].toString();
    } catch (_) {}
    return null;
  }
}