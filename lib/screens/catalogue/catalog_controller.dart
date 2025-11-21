import 'package:flutter/foundation.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/services/produit_service.dart';

class CatalogController extends ChangeNotifier {
  final ProduitService service;

  CatalogController(this.service);

  final List<Produit> items = [];
  bool loading = false;
  String? error;
  int _page = 0;
  bool _hasNext = true;

  // filtres côté serveur (optionnels, si ton API les supporte)
  String? q;
  String? regionId;
  String? categorie; // 'Habit' | 'Plat' | 'Accessoire'
  String? sort;      // 'prix:asc' | 'prix:desc' | etc.

  bool get canLoadMore => _hasNext && !loading;

  Future<void> fetchFirstPage({
    String? q,
    String? regionId,
    String? categorie,
    String? sort,
  }) async {
    this.q = q;
    this.regionId = regionId;
    this.categorie = categorie;
    this.sort = sort;

    items.clear();
    _page = 0;
    _hasNext = true;
    error = null;
    await fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (loading || !_hasNext) return;
    loading = true;
    notifyListeners();

    try {
      final res = await service.fetchCataloguePage(
        page: _page + 1,
        perPage: 20,
        q: q,
        regionId: regionId,
        categorie: categorie,
        sort: sort,
      );
      _page = res.page;
      _hasNext = res.hasNext;
      items.addAll(res.items);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchFirstPage(q: q, regionId: regionId, categorie: categorie, sort: sort);
  }
}