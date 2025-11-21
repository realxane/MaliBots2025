// lib/providers/favoris_store.dart
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/services/auth_storage.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore({
    required this.baseUrl,
    AuthStorage? storage,
  }) : _storage = storage ?? AuthStorage();

  final String baseUrl; // ex: "http://192.168.1.103:8000/api"
  final AuthStorage _storage;

  // ======== PRODUITS (Articles) - dynamiques avec backend ========
  final Set<String> _favProductIds = LinkedHashSet<String>(); // conserve l’ordre d’insertion
  final Map<String, Produit> _productsById = <String, Produit>{};

  bool loadingProducts = false;
  String? lastError;

  List<Produit> get productFavorites =>
      _favProductIds.map((id) => _productsById[id]).whereType<Produit>().toList(growable: false);

  bool isProductFavorite(String productId) => _favProductIds.contains(productId);

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.readToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _setFavoriteLocal(Produit p, {required bool fav}) {
    if (fav) {
      _favProductIds.add(p.id);
      _productsById[p.id] = p;
    } else {
      _favProductIds.remove(p.id);
    }
    notifyListeners();
  }

  // Charge la liste des favoris PRODUIT depuis /favoris?type=Produit
  Future<void> refreshProductFavorites() async {
    loadingProducts = true;
    lastError = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/favoris')
          .replace(queryParameters: {'type': 'Produit', 'perPage': '100'});

      final res = await http.get(uri, headers: await _authHeaders());
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      final json = jsonDecode(res.body);
      final List list = (json is Map && json['data'] is List)
          ? json['data'] as List
          : (json as List);

      final ids = <String>[];
      for (final raw in list) {
        final cibleId = (raw is Map ? (raw['cibleId'] ?? raw['cible_id']) : null)?.toString() ?? '';
        if (cibleId.isEmpty) continue;
        ids.add(cibleId);
      }

      _favProductIds
        ..clear()
        ..addAll(ids);

      // Hydratation produits
      for (final id in _favProductIds) {
        if (!_productsById.containsKey(id)) {
          await _fetchProductById(id);
        }
      }
    } catch (e) {
      lastError = e.toString();
    } finally {
      loadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> _fetchProductById(String id) async {
    final uri = Uri.parse('$baseUrl/produits/$id');
    final res = await http.get(uri, headers: await _authHeaders());
    if (res.statusCode != 200) return;

    final json = jsonDecode(res.body);
    final map = (json is Map && json['data'] is Map)
        ? json['data'] as Map<String, dynamic>
        : (json as Map<String, dynamic>);
    final produit = Produit.fromJson(map);
    _productsById[id] = produit;
  }

  // Toggle via POST /favoris/toggle {cibleType:'Produit', cibleId:'...'} (optimistic UI)
  // Retourne true si ajouté, false si retiré
  Future<bool> toggleProductRemote(Produit p) async {
    final already = isProductFavorite(p.id);

    _setFavoriteLocal(p, fav: !already); // optimistic
    try {
      final uri = Uri.parse('$baseUrl/favoris/toggle');
      final res = await http.post(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode({'cibleType': 'Produit', 'cibleId': p.id}),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final json = jsonDecode(res.body);
      final toggled = (json is Map ? (json['toggled'] ?? json['status']) : null)
          .toString(); // "added" | "removed"
      final added = toggled == 'added' || (!already && toggled.isEmpty);

      if (added != !already) {
        // Corrige si le backend répond différemment de l’optimistic
        _setFavoriteLocal(p, fav: added);
      }

      if (added) _productsById[p.id] = p;
      return added;
    } catch (e) {
      // rollback
      _setFavoriteLocal(p, fav: already);
      lastError = e.toString();
      rethrow;
    }
  }

  Future<bool> toggleProductRemoteById(String productId) async {
    final Produit p = _productsById[productId] ?? await _lazyLoadProduct(productId);
    return toggleProductRemote(p);
  }

  Future<Produit> _lazyLoadProduct(String id) async {
    await _fetchProductById(id);
    // Si l'API /produits/{id} échoue ou ne renvoie rien, on construit un objet minimal
    return _productsById[id] ??
        Produit(
          id: id,
          nom: 'Article $id',
          prix: 0,                 // double?
          images: const [],
          firstImageUrl: 'assets/placeholder.png',
          ratingAvg: 0,
          ratingCount: 0,
        );
  }

  Future<void> removeProductRemote(String productId) async {
    await toggleProductRemoteById(productId);
  }

  // ======== Le reste du store (culture, galerie, musiques) reste inchangé ========

  // --- Contes & Proverbes (stockés localement) ---
  final Map<String, Map<String, String>> _conteFavorites = {};
  final Map<String, Map<String, String>> _proverbeFavorites = {};
  List<Map<String, String>> get conteFavorites => _conteFavorites.values.toList(growable: false);
  List<Map<String, String>> get proverbeFavorites => _proverbeFavorites.values.toList(growable: false);
  String conteIdFrom(Map<String, String> c) => (c['id'] ?? c['titre'] ?? '').trim().toLowerCase();
  String proverbeIdFrom(Map<String, String> p) => (p['id'] ?? p['texte'] ?? '').trim().toLowerCase();
  bool isConteFavorite(String id) => _conteFavorites.containsKey(id);
  bool isProverbeFavorite(String id) => _proverbeFavorites.containsKey(id);
  bool isConteFavoriteByMap(Map<String, String> c) => isConteFavorite(conteIdFrom(c));
  bool isProverbeFavoriteByMap(Map<String, String> p) => isProverbeFavorite(proverbeIdFrom(p));
  void toggleConte(Map<String, String> c) {
    final id = conteIdFrom(c);
    if (_conteFavorites.containsKey(id)) {
      _conteFavorites.remove(id);
    } else {
      _conteFavorites[id] = {...c, 'id': id};
    }
    notifyListeners();
  }
  void toggleProverbe(Map<String, String> p) {
    final id = proverbeIdFrom(p);
    if (_proverbeFavorites.containsKey(id)) {
      _proverbeFavorites.remove(id);
    } else {
      _proverbeFavorites[id] = {...p, 'id': id};
    }
    notifyListeners();
  }
  void removeConte(String id) {
    _conteFavorites.remove(id);
    notifyListeners();
  }
  void removeProverbe(String id) {
    _proverbeFavorites.remove(id);
    notifyListeners();
  }

  // --- Galerie ---
  final List<Map<String, dynamic>> _photoFavorites = [];
  List<Map<String, dynamic>> get photoFavorites => List.unmodifiable(_photoFavorites);
  String photoIdFrom(Map<String, dynamic> photo) {
    final titre = (photo['titre'] ?? '').toString().trim().toLowerCase();
    final firstImg = (photo['images'] is List && photo['images'].isNotEmpty)
        ? (photo['images'][0] ?? '').toString()
        : '';
    return '${titre}__$firstImg';
  }
  bool isPhotoFavorite(String photoId) {
    return _photoFavorites.any((p) => photoIdFrom(p) == photoId);
  }
  bool isPhotoFavoriteBy(Map<String, dynamic> photo) {
    return isPhotoFavorite(photoIdFrom(photo));
  }
  void togglePhoto(Map<String, dynamic> photo) {
    final id = photoIdFrom(photo);
    if (isPhotoFavorite(id)) {
      removePhoto(id);
    } else {
      _photoFavorites.add(photo);
      notifyListeners();
    }
  }
  void removePhoto(String photoId) {
    _photoFavorites.removeWhere((p) => photoIdFrom(p) == photoId);
    notifyListeners();
  }
  void clearPhotoFavorites() {
    _photoFavorites.clear();
    notifyListeners();
  }

  // --- Musiques ---
  final List<Map<String, dynamic>> _musicFavorites = [];
  List<Map<String, dynamic>> get musicFavorites => List.unmodifiable(_musicFavorites);
  String musicIdFrom(Map<String, dynamic> track) {
    final path = (track['path'] ?? '').toString();
    final title = (track['title'] ?? '').toString().trim().toLowerCase();
    final artist = (track['artist'] ?? '').toString().trim().toLowerCase();
    return '${path}__${title}__${artist}';
  }
  bool isMusicFavorite(String musicId) => _musicFavorites.any((m) => musicIdFrom(m) == musicId);
  bool isMusicFavoriteBy(Map<String, dynamic> track) => isMusicFavorite(musicIdFrom(track));
  void toggleMusic(Map<String, dynamic> track) {
    final id = musicIdFrom(track);
    if (isMusicFavorite(id)) {
      removeMusic(id);
    } else {
      _musicFavorites.add(track);
      notifyListeners();
    }
  }
  void removeMusic(String musicId) {
    _musicFavorites.removeWhere((m) => musicIdFrom(m) == musicId);
    notifyListeners();
  }
  void clearMusicFavorites() {
    _musicFavorites.clear();
    notifyListeners();
  }
}