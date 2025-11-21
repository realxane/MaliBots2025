import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:malibots_challenge_eni/services/auth_storage.dart';
import 'package:malibots_challenge_eni/utils/image_urls.dart';

class ServerCartItem {
  final String itemId;
  final String produitId;
  final String nom;
  final int price; // prix unitaire en FCFA (int)
  final int quantite;
  final String imageUrlBest;

  ServerCartItem({
    required this.itemId,
    required this.produitId,
    required this.nom,
    required this.price,
    required this.quantite,
    required this.imageUrlBest,
  });
}

class ServerCart {
  final String id;
  final String acheteurId;
  final List<ServerCartItem> items;
  final int nbItems;
  final int subtotal;

  ServerCart({
    required this.id,
    required this.acheteurId,
    required this.items,
    required this.nbItems,
    required this.subtotal,
  });
}

class CartApi {
  CartApi({required this.baseUrl, AuthStorage? storage})
      : _storage = storage ?? AuthStorage();

  final String baseUrl;
  final AuthStorage _storage;

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.readToken();
    String? auth;
    if (token != null && token.isNotEmpty) {
      final t = token.trim();
      auth = t.toLowerCase().startsWith('bearer ') ? t : 'Bearer $t';
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (auth != null) 'Authorization': auth,
    };
  }

  // ------------ parsing helpers ------------

  int _intFrom(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.split('.').first) ?? 0;
    return 0;
  }

  double _doubleFrom(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  ServerCart _parseCart(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ?? const [];
    final items = <ServerCartItem>[];

    for (final raw in itemsJson) {
      if (raw is! Map<String, dynamic>) continue;

      final produit = (raw['produit'] as Map?) ?? const {};
      final produitId = (raw['produitId'] ?? produit['id'] ?? '').toString();
      final nom = (produit['nom'] ?? 'Article').toString();

      // prixUnitaire vient comme string "2500.00"
      final prixUnitaire = _doubleFrom(raw['prixUnitaire']);
      final priceInt = prixUnitaire.round();

      // imageUrl éventuellement relative -> normalizeImageRef
      final rawImage = (produit['imageUrl'] ?? '').toString();
      final normalized = normalizeImageRef(rawImage);

      items.add(
        ServerCartItem(
          itemId: (raw['id'] ?? '').toString(),
          produitId: produitId,
          nom: nom,
          price: priceInt,
          quantite: _intFrom(raw['quantite']),
          imageUrlBest: normalized,
        ),
      );
    }

    final subtotalDouble = _doubleFrom(json['subtotal']);
    final subtotalInt = subtotalDouble.round();

    return ServerCart(
      id: (json['id'] ?? '').toString(),
      acheteurId: (json['acheteurId'] ?? '').toString(),
      items: items,
      nbItems: _intFrom(json['nbItems']),
      subtotal: subtotalInt,
    );
  }

  Map<String, dynamic> _extractCartJson(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw Exception('Réponse panier inattendue');
    }

    // Plusieurs formats possibles côté Laravel
    if (body['items'] is List) {
      // { id, acheteurId, items: [...] }
      return body;
    }
    if (body['panier'] is Map<String, dynamic>) {
      return body['panier'] as Map<String, dynamic>;
    }
    if (body['cart'] is Map<String, dynamic>) {
      return body['cart'] as Map<String, dynamic>;
    }
    if (body['data'] is Map<String, dynamic>) {
      final data = body['data'] as Map<String, dynamic>;
      if (data['items'] is List) return data;
    }

    throw Exception('Structure de panier non reconnue: $body');
  }

  // ------------ endpoints ------------

  /// GET /acheteur/panier
  Future<ServerCart> getCart() async {
    final uri = Uri.parse('$baseUrl/acheteur/panier');
    debugPrint('🧺 [CART] GET $uri');

    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 20));

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('Non autorisé pour /acheteur/panier (${res.statusCode})');
    }
    if (res.statusCode != 200) {
      throw Exception(
          'Erreur ${res.statusCode} sur /acheteur/panier: ${res.body}');
    }

    final raw = res.body.isEmpty ? {} : jsonDecode(res.body);
    final cartJson = _extractCartJson(raw);

    return _parseCart(cartJson);
  }

  /// POST /acheteur/panier/items
  Future<ServerCart> addItem({
    required String produitId,
    required int quantite,
  }) async {
    final uri = Uri.parse('$baseUrl/acheteur/panier/items');
    final payload = {
      'produitId': produitId,
      'quantite': quantite,
    };
    debugPrint('🧺 [CART] POST $uri body=$payload');

    final res = await http
        .post(
          uri,
          headers: await _authHeaders(),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('Non autorisé pour POST /acheteur/panier/items');
    }
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(
          'Erreur ${res.statusCode} sur POST /acheteur/panier/items: ${res.body}');
    }

    // 1) On essaie d'extraire un panier directement de la réponse
    try {
      final raw = res.body.isEmpty ? {} : jsonDecode(res.body);
      final cartJson = _extractCartJson(raw);
      return _parseCart(cartJson);
    } catch (e, st) {
      debugPrint('🧺 [CART] Impossible de parser la réponse POST comme panier: $e\n$st');
    }

    // 2) Fallback : on recharge le panier complet
    debugPrint('🧺 [CART] POST sans panier exploitable, fallback GET /acheteur/panier');
    return getCart();
  }

  /// PATCH /acheteur/panier/items/{item}
  Future<ServerCart> updateItemQty({
    required String itemId,
    required int quantite,
  }) async {
    final uri = Uri.parse('$baseUrl/acheteur/panier/items/$itemId');
    final payload = {'quantite': quantite};
    debugPrint('🧺 [CART] PATCH $uri body=$payload');

    final res = await http
        .patch(uri,
            headers: await _authHeaders(), body: jsonEncode(payload))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('Non autorisé pour PATCH /acheteur/panier/items/$itemId');
    }
    if (res.statusCode != 200) {
      throw Exception(
          'Erreur ${res.statusCode} sur PATCH /acheteur/panier/items/$itemId: ${res.body}');
    }

    final raw = res.body.isEmpty ? {} : jsonDecode(res.body);
    final cartJson = _extractCartJson(raw);

    return _parseCart(cartJson);
  }

  /// DELETE /acheteur/panier/items/{item}
  Future<void> removeItem({required String itemId}) async {
    final uri = Uri.parse('$baseUrl/acheteur/panier/items/$itemId');
    debugPrint('🧺 [CART] DELETE $uri');

    final res = await http
        .delete(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 20));

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception(
          'Non autorisé pour DELETE /acheteur/panier/items/$itemId');
    }
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception(
          'Erreur ${res.statusCode} sur DELETE /acheteur/panier/items/$itemId: ${res.body}');
    }
  }
}