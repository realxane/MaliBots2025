import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/models/product.dart';

class FavoritesStore extends ChangeNotifier {
  // Favoris pour les produits (Articles = Habits, Plats, Accessoires)
  final List<Product> _productFavorites = [];

  List<Product> get productFavorites => List.unmodifiable(_productFavorites);

  bool isProductFavorite(String productId) =>
      _productFavorites.any((p) => p.id == productId);

  void toggleProduct(Product p) {
    final i = _productFavorites.indexWhere((e) => e.id == p.id);
    if (i >= 0) {
      _productFavorites.removeAt(i);
    } else {
      _productFavorites.add(p);
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _productFavorites.removeWhere((e) => e.id == productId);
    notifyListeners();
  }

  //Favoris pour la culture
  // --- Contes & Proverbes (stockés par id) ---
  final Map<String, Map<String, String>> _conteFavorites = {};
  final Map<String, Map<String, String>> _proverbeFavorites = {};

  // Expositions
  List<Map<String, String>> get conteFavorites =>
      _conteFavorites.values.toList(growable: false);
  List<Map<String, String>> get proverbeFavorites =>
      _proverbeFavorites.values.toList(growable: false);

  // Génération d'ID stables (préfère 'id' si présent, sinon titre/texte)
  String conteIdFrom(Map<String, String> c) =>
      (c['id'] ?? c['titre'] ?? '').trim().toLowerCase();

  String proverbeIdFrom(Map<String, String> p) =>
      (p['id'] ?? p['texte'] ?? '').trim().toLowerCase();

  // Helpers "isFavorite"
  bool isConteFavorite(String id) => _conteFavorites.containsKey(id);
  bool isProverbeFavorite(String id) => _proverbeFavorites.containsKey(id);

  bool isConteFavoriteByMap(Map<String, String> c) =>
      isConteFavorite(conteIdFrom(c));
  bool isProverbeFavoriteByMap(Map<String, String> p) =>
      isProverbeFavorite(proverbeIdFrom(p));

  // Toggle / remove
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

  // --- Galerie: favoris de photos ---
  final List<Map<String, dynamic>> _photoFavorites = [];

  List<Map<String, dynamic>> get photoFavorites =>
      List.unmodifiable(_photoFavorites);

  // Génère un identifiant stable pour une photo (titre + première image).
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
}