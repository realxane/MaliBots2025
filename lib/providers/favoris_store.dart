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
}