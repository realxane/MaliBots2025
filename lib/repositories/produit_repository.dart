import '../api/produit_api.dart';
import '../models/product.dart';
import '../api/paginated.dart';

class ProduitRepository {
  final ProduitApi api;
  ProduitRepository(this.api);

  Future<Paginated<Produit>> getMyProduits({String? categorie, String? statut, int page = 1}) {
    return api.list(categorie: categorie, statut: statut, page: page);
  }

  Future<Produit> get(String id) => api.show(id);
}