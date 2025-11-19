import 'package:flutter/foundation.dart';
import '../../api/paginated.dart';
import '../../models/product.dart';
import '../../repositories/produit_repository.dart';

class CatalogController extends ChangeNotifier {
  final ProduitRepository repo;
  CatalogController(this.repo);

  bool loading = false;
  String? error;
  List<Produit> items = [];

  Future<void> fetchFirstPage({String? categorie}) async {
    loading = true; error = null; notifyListeners();
    try {
      final page = await repo.getMyProduits(categorie: categorie, page: 1);
      items = page.data;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false; notifyListeners();
    }
  }
}