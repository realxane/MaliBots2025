import '../models/product.dart';
import './api_client.dart';
import './paginated.dart';

class ProduitApi {
  final ApiClient _api;
  ProduitApi(this._api);

  Future<Paginated<Produit>> list({
    String? categorie,
    String? statut,
    bool withTrashed = false,
    int page = 1,
    int perPage = 15,
  }) async {
    final json = await _api.get('/vendeur/produits', query: {
      'categorie': categorie,
      'statut': statut,
      'withTrashed': withTrashed ? '1' : null,
      'page': page,
      'perPage': perPage,
    });
    return Paginated.fromJson(json, (m) => Produit.fromJson(m));
  }

  Future<Produit> show(String id) async {
    final json = await _api.get('/vendeur/produits/$id');
    return Produit.fromJson(json);
  }

  Future<Produit> create(Map<String, dynamic> body) async {
    final json = await _api.post('/vendeur/produits', body);
    return Produit.fromJson(json);
  }

  Future<Produit> update(String id, Map<String, dynamic> body) async {
    final json = await _api.put('/vendeur/produits/$id', body);
    return Produit.fromJson(json);
  }

  Future<void> delete(String id) async => _api.delete('/vendeur/produits/$id');

  Future<Produit> restore(String id) async {
    final json = await _api.patch('/vendeur/produits/$id/restore', {});
    return Produit.fromJson(json);
  }
}