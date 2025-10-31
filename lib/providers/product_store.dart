// lib/providers/products_store.dart
import 'package:flutter/foundation.dart';
import 'package:malibots_challenge_eni/models/product.dart';

class ProductsStore with ChangeNotifier {
  final Map<String, Product> _byId;

  ProductsStore(List<Product> all)
      : _byId = {for (final p in all) p.id: p};

  Product? byId(String id) => _byId[id];
}