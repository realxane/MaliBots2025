import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:malibots_challenge_eni/config/api_config.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/models/photo.dart';
import 'package:malibots_challenge_eni/models/musique.dart';
import 'package:malibots_challenge_eni/services/auth_storage.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore({AuthStorage? storage}) : _storage = storage ?? AuthStorage();

  /// URL de base de l’API (centralisée)
  final String baseUrl = kApiBaseUrl;
  final AuthStorage _storage;

  // ======== PRODUITS (Articles) - dynamiques avec backend ========
  final Set<String> _favProductIds = LinkedHashSet<String>();
  final Map<String, Produit> _productsById = <String, Produit>{};

  bool loadingProducts = false;
  String? lastError;

  // ---------- Helpers ----------
  bool _disposed = false;
  bool _notifyScheduled = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notifySafely() {
    if (_disposed || !hasListeners || _notifyScheduled) return;
    _notifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      if (!_disposed && hasListeners) {
        notifyListeners();
      }
    });
  }

  // --------- PRODUITS ---------

  List<Produit> get productFavorites =>
      _favProductIds.map((id) => _productsById[id]).whereType<Produit>().toList(
            growable: false,
          );

  bool isProductFavorite(String productId) => _favProductIds.contains(productId);

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

  void _setFavoriteLocal(Produit p, {required bool fav}) {
    if (fav) {
      _favProductIds.add(p.id);
      _productsById[p.id] = p;
    } else {
      _favProductIds.remove(p.id);
    }
    _notifySafely();
  }

  // --------- CHARGEMENT DES FAVORIS PRODUITS ---------

  Future<void> refreshProductFavorites() async {
    if (loadingProducts) return;
    loadingProducts = true;
    lastError = null;
    _notifySafely();

    try {
      final uri = Uri.parse('$baseUrl/favoris').replace(
        queryParameters: {
          'type': 'Produit',
          'perPage': '100',
        },
      );

      debugPrint('⭐ [FAVORIS] GET $uri');

      final res = await http
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 20));

      debugPrint('⭐ [FAVORIS] status: ${res.statusCode}');
      if (res.statusCode == 401 || res.statusCode == 403) {
        throw Exception('Non autorisé (HTTP ${res.statusCode}) pour /favoris');
      }

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode} sur /favoris: ${res.body}');
      }

      if (res.body.isEmpty) {
        debugPrint('⚠️ [FAVORIS] Réponse vide pour /favoris');
        _favProductIds.clear();
        _notifySafely();
        return;
      }

      dynamic jsonBody;
      try {
        jsonBody = jsonDecode(res.body);
      } catch (e) {
        throw Exception('JSON invalide pour /favoris: ${e.toString()}');
      }

      List list;
      if (jsonBody is Map<String, dynamic>) {
        if (jsonBody['data'] is List) {
          list = jsonBody['data'] as List;
        } else {
          debugPrint(
            '⚠️ [FAVORIS] format inattendu: data != List => ${jsonBody['data']}',
          );
          list = const [];
        }
      } else if (jsonBody is List) {
        list = jsonBody;
      } else {
        debugPrint('⚠️ [FAVORIS] corps inattendu: ${jsonBody.runtimeType}');
        list = const [];
      }

      final ids = <String>[];
      for (final raw in list) {
        if (raw is! Map) continue;

        final cibleId =
            (raw['cibleId'] ?? raw['cible_id'])?.toString().trim() ?? '';

        if (cibleId.isEmpty) continue;
        ids.add(cibleId);
      }

      debugPrint('⭐ [FAVORIS] ids produits trouvés = $ids');

      _favProductIds
        ..clear()
        ..addAll(ids);

      final futures = <Future<void>>[];
      for (final id in _favProductIds) {
        if (!_productsById.containsKey(id)) {
          futures.add(_fetchProductById(id));
        }
      }
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
    } catch (e, st) {
      lastError = e.toString();
      debugPrint('❌ [FAVORIS] refresh error: $e');
      debugPrint('❌ [FAVORIS] stack: $st');
    } finally {
      loadingProducts = false;
      _notifySafely();
    }
  }

  Future<void> _fetchProductById(String id) async {
    final uri = Uri.parse('$baseUrl/produits/$id');
    debugPrint('⭐ [FAVORIS] GET $uri');

    try {
      final res = await http
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 20));

      debugPrint(
        '⭐ [FAVORIS] /produits/$id -> ${res.statusCode} body: ${res.body}',
      );

      if (res.statusCode == 404) {
        debugPrint('⚠️ [FAVORIS] produit $id introuvable (404)');
        return;
      }
      if (res.statusCode != 200) {
        debugPrint(
          '❌ [FAVORIS] fetch product $id: HTTP ${res.statusCode}: ${res.body}',
        );
        return;
      }

      if (res.body.isEmpty) {
        debugPrint('⚠️ [FAVORIS] produit $id: corps vide');
        return;
      }

      dynamic jsonBody;
      try {
        jsonBody = jsonDecode(res.body);
      } catch (e) {
        debugPrint(
          '❌ [FAVORIS] JSON invalide pour /produits/$id: ${e.toString()}',
        );
        return;
      }

      Map<String, dynamic> map;
      if (jsonBody is Map<String, dynamic>) {
        if (jsonBody['data'] is Map<String, dynamic>) {
          map = jsonBody['data'] as Map<String, dynamic>;
        } else {
          map = jsonBody;
        }
      } else {
        debugPrint(
          '⚠️ [FAVORIS] format produit inattendu: ${jsonBody.runtimeType}',
        );
        return;
      }

      final produit = Produit.fromJson(map);
      _productsById[id] = produit;
      _notifySafely();
    } catch (e, st) {
      debugPrint('❌ [FAVORIS] _fetchProductById($id) error: $e');
      debugPrint('❌ [FAVORIS] stack: $st');
    }
  }

  // Toggle via POST /favoris/toggle
  Future<bool> toggleProductRemote(Produit p) async {
    final already = isProductFavorite(p.id);

    _setFavoriteLocal(p, fav: !already);

    try {
      final uri = Uri.parse('$baseUrl/favoris/toggle');
      final headers = await _authHeaders();
      final bodyMap = {'cibleType': 'Produit', 'cibleId': p.id};

      debugPrint('⭐ [FAVORIS] POST $uri');
      debugPrint('⭐ [FAVORIS] headers: $headers');
      debugPrint('⭐ [FAVORIS] body: $bodyMap');

      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      debugPrint('⭐ [FAVORIS] status: ${res.statusCode}, body: ${res.body}');

      if (res.statusCode == 401 || res.statusCode == 403) {
        throw Exception(
          'Non autorisé (HTTP ${res.statusCode}) sur /favoris/toggle',
        );
      }

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;

      bool? addedFromResponse;
      if (body is Map) {
        final raw = body['toggled'] ??
            body['status'] ??
            body['added'] ??
            body['isFavorite'] ??
            body['favorite'] ??
            body['favori'] ??
            body['is_favorite'];
        if (raw is bool) {
          addedFromResponse = raw;
        } else if (raw is num) {
          addedFromResponse = raw != 0;
        } else if (raw is String) {
          final s = raw.toLowerCase();
          if (s == 'added' ||
              s == 'created' ||
              s == 'true' ||
              s == '1' ||
              s == 'ajoute' ||
              s == 'ok') {
            addedFromResponse = true;
          } else if (s == 'removed' ||
              s == 'deleted' ||
              s == 'false' ||
              s == '0' ||
              s == 'retire') {
            addedFromResponse = false;
          }
        }
      }

      final added = addedFromResponse ?? (!already);

      if (added != !already) {
        _setFavoriteLocal(p, fav: added);
      }

      if (added) _productsById[p.id] = p;
      return added;
    } catch (e) {
      _setFavoriteLocal(p, fav: already);
      lastError = e.toString();
      debugPrint('❌ [FAVORIS] toggle error: $e');
      rethrow;
    }
  }

  Future<bool> toggleProductRemoteById(String productId) async {
    final Produit p =
        _productsById[productId] ?? await _lazyLoadProduct(productId);
    return toggleProductRemote(p);
  }

  Future<Produit> _lazyLoadProduct(String id) async {
    await _fetchProductById(id);
    return _productsById[id] ??
        Produit(
          id: id,
          nom: 'Article $id',
          prix: 0,
          images: const [],
          firstImageUrl: 'assets/placeholder.png',
          ratingAvg: 0,
          ratingCount: 0,
        );
  }

  Future<void> removeProductRemote(String productId) async {
    await toggleProductRemoteById(productId);
  }

  // ====================================================================
  // 2. Favoris pour la culture (Contes & Proverbes)
  // ====================================================================

  final Map<String, Map<String, String>> _conteFavorites = {};
  final Map<String, Map<String, String>> _proverbeFavorites = {};

  List<Map<String, String>> get conteFavorites =>
      _conteFavorites.values.toList(growable: false);

  List<Map<String, String>> get proverbeFavorites =>
      _proverbeFavorites.values.toList(growable: false);

  String conteIdFrom(Map<String, String> c) =>
      (c['id'] ?? c['titre'] ?? '').trim().toLowerCase();

  String proverbeIdFrom(Map<String, String> p) =>
      (p['id'] ?? p['texte'] ?? '').trim().toLowerCase();

  bool isConteFavorite(String id) => _conteFavorites.containsKey(id);
  bool isProverbeFavorite(String id) => _proverbeFavorites.containsKey(id);
  bool isConteFavoriteByMap(Map<String, String> c) =>
      isConteFavorite(conteIdFrom(c));
  bool isProverbeFavoriteByMap(Map<String, String> p) =>
      isProverbeFavorite(proverbeIdFrom(p));

  void toggleConte(Map<String, String> c) {
    final id = conteIdFrom(c);
    if (_conteFavorites.containsKey(id)) {
      _conteFavorites.remove(id);
    } else {
      _conteFavorites[id] = {...c, 'id': id};
    }
    _notifySafely();
  }

  void toggleProverbe(Map<String, String> p) {
    final id = proverbeIdFrom(p);
    if (_proverbeFavorites.containsKey(id)) {
      _proverbeFavorites.remove(id);
    } else {
      _proverbeFavorites[id] = {...p, 'id': id};
    }
    _notifySafely();
  }

  void removeConte(String id) {
    _conteFavorites.remove(id);
    _notifySafely();
  }

  void removeProverbe(String id) {
    _proverbeFavorites.remove(id);
    _notifySafely();
  }

  // ====================================================================
  // 3. Galerie: favoris de photos (modèle Photo)
  // ====================================================================

  final List<Photo> _photoFavorites = [];

  List<Photo> get photoFavorites => List.unmodifiable(_photoFavorites);

  String getPhotoId(Photo photo) => photo.id;

  bool isPhotoFavorite(String photoId) {
    return _photoFavorites.any((p) => p.id == photoId);
  }

  bool isPhotoFavoriteBy(Photo photo) {
    return isPhotoFavorite(getPhotoId(photo));
  }

  void togglePhoto(Photo photo) {
    final id = getPhotoId(photo);

    if (isPhotoFavorite(id)) {
      removePhoto(id);
    } else {
      _photoFavorites.add(photo);
      _notifySafely();
    }
  }

  void removePhoto(String photoId) {
    _photoFavorites.removeWhere((p) => p.id == photoId);
    _notifySafely();
  }

  void clearPhotoFavorites() {
    _photoFavorites.clear();
    _notifySafely();
  }

  // ====================================================================
  // 4. Favoris Musiques (modèle Musique)
  // ====================================================================

  final List<Musique> _musicFavorites = [];

  List<Musique> get musicFavorites => List.unmodifiable(_musicFavorites);

  bool isMusicFavoriteBy(Musique music) =>
      _musicFavorites.any((m) => m.id == music.id);

  void toggleMusic(Musique music) {
    final isExisting = isMusicFavoriteBy(music);
    if (isExisting) {
      _musicFavorites.removeWhere((m) => m.id == music.id);
    } else {
      _musicFavorites.add(music);
    }
    _notifySafely();
  }

  void removeMusic(String musicId) {
    _musicFavorites.removeWhere((m) => m.id == musicId);
    _notifySafely();
  }

  void clearMusicFavorites() {
    _musicFavorites.clear();
    _notifySafely();
  }
}