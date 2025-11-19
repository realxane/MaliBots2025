import '../api/produit_api.dart';
import '../api/image_uploader.dart';
import '../models/product.dart';
import '../mappers/ui_backend_maps.dart';

class ProduitService {
  final ProduitApi api;
  final ImageUploader uploader;

  ProduitService({required this.api, required this.uploader});

  // Créer depuis ton écran UI (product “local”)
  Future<Produit> createFromUi({
    required String nom,
    String? description,
    required double prix,
    required String uiCategorie,
    required String regionLabel,
    required int stock,
    required List<String> imageLocalPathsOrUrls,
  }) async {
    // 1) Upload des fichiers “locaux”; on garde les URLs déjà http(s)
    final toUpload = <String>[];
    final passThrough = <String>[];
    for (final p in imageLocalPathsOrUrls) {
      if (p.startsWith('http://') || p.startsWith('https://')) {
        passThrough.add(p);
      } else {
        toUpload.add(p);
      }
    }
    final uploaded = toUpload.isEmpty ? <String>[] : await uploader.uploadAll(toUpload);
    final images = [...passThrough, ...uploaded];

    // 2) Mappage catégories & régions
    final categorie = uiToBackendCategorie(uiCategorie);
    final regionId = uiRegionLabelToId(regionLabel);

    final body = {
      'nom': nom,
      if (description != null && description.isNotEmpty) 'description': description,
      'prix': double.parse(prix.toStringAsFixed(2)),
      'categorie': categorie,
      if (regionId != null) 'regionId': regionId, // évite 422 si ID inconnu
      'stock': stock,
      'images': images, // le controller Laravel les gère
    };

    return api.create(body);
  }

  Future<Produit> updateFromUi({
    required String id,
    required String nom,
    String? description,
    required double prix,
    required String uiCategorie,
    required String regionLabel,
    required int stock,
    required List<String> imageLocalPathsOrUrls,
  }) async {
    final toUpload = <String>[];
    final passThrough = <String>[];
    for (final p in imageLocalPathsOrUrls) {
      if (p.startsWith('http://') || p.startsWith('https://')) {
        passThrough.add(p);
      } else {
        toUpload.add(p);
      }
    }
    final uploaded = toUpload.isEmpty ? <String>[] : await uploader.uploadAll(toUpload);
    final images = [...passThrough, ...uploaded];

    final categorie = uiToBackendCategorie(uiCategorie);
    final regionId = uiRegionLabelToId(regionLabel);

    final body = {
      'nom': nom,
      if (description != null && description.isNotEmpty) 'description': description,
      'prix': double.parse(prix.toStringAsFixed(2)),
      'categorie': categorie,
      if (regionId != null) 'regionId': regionId,
      'stock': stock,
      'images': images, // remplace l’ensemble côté backend
    };

    return api.update(id, body);
  }
}