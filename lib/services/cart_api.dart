// lib/services/cart_api.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // compute
import 'package:malibots_challenge_eni/services/auth_storage.dart';

class CartApi {
  CartApi({required this.baseUrl, AuthStorage? storage})
      : _storage = storage ?? AuthStorage();

  final String baseUrl; // ex: "http://192.168.1.103:8000/api"
  final AuthStorage _storage;

  static const Duration _defaultTimeout = Duration(seconds: 10);

  Future<Map<String, String>> _headers() async {
    final token = await _storage.readToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ---------- Parsing asynchrone pour fluidité ----------
  Future<ApiCart> _parseCartAsync(String body) {
    return compute(_parseCartImpl, body);
  }

  static ApiCart _parseCartImpl(String body) {
    final json = jsonDecode(body);
    return ApiCart.fromJson(json);
  }

  Future<ApiCart> getCart() async {
    final uri = Uri.parse('$baseUrl/acheteur/panier');
    final res = await http
        .get(uri, headers: await _headers())
        .timeout(_defaultTimeout);
    if (res.statusCode == 200) {
      return _parseCartAsync(res.body);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  // POST /acheteur/panier/items
  Future<ApiCart> addItem({
    required String produitId,
    required int quantite,
    num? prixUnitaire,
  }) async {
    final uri = Uri.parse('$baseUrl/acheteur/panier/items');
    final payload = <String, dynamic>{
      'produitId': produitId,
      'quantite': quantite,
      if (prixUnitaire != null) 'prixUnitaire': prixUnitaire,
    };
    final res = await http
        .post(uri, headers: await _headers(), body: jsonEncode(payload))
        .timeout(_defaultTimeout);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return _parseCartAsync(res.body);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  // PATCH /acheteur/panier/items/{item}
  Future<ApiCart> updateItemQty({
    required String itemId,
    required int quantite,
  }) async {
    final uri = Uri.parse('$baseUrl/acheteur/panier/items/$itemId');
    final payload = {'quantite': quantite};
    final res = await http
        .patch(uri, headers: await _headers(), body: jsonEncode(payload))
        .timeout(_defaultTimeout);

    if (res.statusCode == 200) {
      return _parseCartAsync(res.body);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  // DELETE /acheteur/panier/items/{item}
  Future<void> removeItem({required String itemId}) async {
    final uri = Uri.parse('$baseUrl/acheteur/panier/items/$itemId');
    final res =
        await http.delete(uri, headers: await _headers()).timeout(_defaultTimeout);
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  // DELETE /acheteur/panier (vider)
  Future<void> clear() async {
    final uri = Uri.parse('$baseUrl/acheteur/panier');
    final res =
        await http.delete(uri, headers: await _headers()).timeout(_defaultTimeout);
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}

// ---------------- DTOs Panier ----------------

class ApiCart {
  ApiCart({required this.items});
  final List<ApiCartItem> items;

  factory ApiCart.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map) ? json['data'] as Map<String, dynamic> : json;
    final rawItems = (root['items'] is List) ? (root['items'] as List) : const [];
    final parsed = <ApiCartItem>[];
    for (final e in rawItems) {
      if (e is Map<String, dynamic>) {
        parsed.add(ApiCartItem.fromJson(e));
      }
    }
    return ApiCart(items: parsed);
  }
}

class ApiCartItem {
  ApiCartItem({
    required this.itemId,
    required this.produitId,
    required this.quantite,
    required this.nom,
    required this.price,          // int (FCFA)
    required this.imageUrlBest,   // asset ou URL
  });

  final String itemId;     // id PanierItem côté serveur
  final String produitId;
  final int quantite;
  final String nom;
  final int price;
  final String imageUrlBest;

  factory ApiCartItem.fromJson(Map<String, dynamic> j) {
    String _s(dynamic v) => v == null ? '' : v.toString();

    int _i(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.round();
      if (v is String) {
        // Nettoyage: garde chiffres, signes et séparateurs, puis parse décimal
        final cleaned = v.replaceAll(RegExp(r'[^\d,.\-]'), '');
        if (cleaned.isEmpty) return 0;
        final normalized = cleaned.replaceAll(',', '.');
        final d = double.tryParse(normalized);
        return d?.round() ?? int.tryParse(cleaned.replaceAll(RegExp(r'\D'), '')) ?? 0;
      }
      return 0;
    }

    final produit = (j['produit'] is Map) ? j['produit'] as Map<String, dynamic> : const {};

    // Recherche d'une image plausible
    String firstImage(Map p) {
      String _saf(dynamic v) => v == null ? '' : v.toString();
      final fiu = _saf(p['firstImageUrl'] ?? p['first_image_url']);
      if (fiu.isNotEmpty) return fiu;
      final compat = _saf(p['imageUrl'] ?? p['image_url']);
      if (compat.isNotEmpty) return compat;
      final imgs = p['images'];
      if (imgs is List && imgs.isNotEmpty) {
        final any = imgs.first;
        if (any is String) return any;
        if (any is Map && any['url'] != null) return _saf(any['url']);
      }
      return '';
    }

    // Champs possibles selon API
    final prixUnitaire = _i(j['prixUnitaire'] ?? j['prix_unitaire']);
    final prixProduit =
        _i(produit['prix'] ?? produit['prixVente'] ?? produit['prix_vente'] ?? j['prix']);

    return ApiCartItem(
      itemId: _s(j['id'] ?? j['itemId'] ?? j['item_id']),
      produitId: _s(j['produitId'] ?? j['produit_id'] ?? produit['id']),
      quantite: _i(j['quantite'] ?? j['qty'] ?? j['quantity']),
      nom: _s(produit['nom'] ?? j['nom'] ?? produit['designation'] ?? 'Produit'),
      price: prixUnitaire != 0 ? prixUnitaire : prixProduit,
      imageUrlBest: firstImage(produit),
    );
  }
}