// class Product {
//   final String id;
//   final String name;
//   final String region;     // Bamako, Kayes, Koulikoro, Sikasso, Segou, Mopti, Tombouctou, Gao, Kidal
//   final String type;       // Nourriture, Habits, Accessoires
//   final String artisan;    // Nom de l’artisan
//   final int price;         // en FCFA
//   final double rating;     // 0..5
//   final int likes;
//   final String imageUrl;

//   Product({
//     required this.id,
//     required this.name,
//     required this.region,
//     required this.type,
//     required this.artisan,
//     required this.price,
//     required this.rating,
//     required this.likes,
//     required this.imageUrl,
//   });
// }

// lib/models/product.dart
import 'dart:convert';

class Produit {
  final String id;
  final String nom;
  final String? description;
  final double? prix;              // ex: 2500.00
  final String? categorie;         // 'Habit' | 'Plat' | 'Accessoire'
  final String? regionId;          // UUID/code ou label court
  final String? regionName;        // Label lisible (ex: "Bamako")
  final List<String> images;       // URLs/paths
  final String? firstImageUrl;     // pré-calculé si dispo
  @Deprecated('Compat: backend deprecates imageUrl')
  final String? imageUrl;          // fallback
  final String? statut;            // 'en_attente' | 'valide' | 'refuse' | 'supprime'
  final String? vendeurId;
  final int? stock;
  final double? ratingAvg;         // 0..5
  final int? ratingCount;          // nb d’avis/likes

  // Ajout pour compat UI
  final String? artisan;

  const Produit({
    required this.id,
    required this.nom,
    this.description,
    this.prix,
    this.categorie,
    this.regionId,
    this.regionName,
    this.images = const [],
    this.firstImageUrl,
    this.imageUrl,
    this.statut,
    this.vendeurId,
    this.stock,
    this.ratingAvg,
    this.ratingCount,
    this.artisan,
  });

  // ---------- Parsing JSON polyvalent ----------
  static Map<String, dynamic> _unwrap(Map<String, dynamic> j) {
    if (j['data'] is Map<String, dynamic>) return j['data'] as Map<String, dynamic>;
    return j;
  }

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.'));
    return null;
  }

  static int? _i(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static String? _s(dynamic v) => v == null ? null : v.toString();

  static List<String> _images(dynamic v) {
    if (v == null) return const [];
    if (v is List) {
      final out = <MapEntry<int, String>>[];
      for (final e in v) {
        if (e is String) {
          out.add(MapEntry(999999, e));
        } else if (e is Map) {
          final url = _s(e['url']);
          if (url != null && url.isNotEmpty) {
            final pos = _i(e['position']) ?? 999999;
            out.add(MapEntry(pos, url));
          }
        }
      }
      out.sort((a, b) => a.key.compareTo(b.key));
      return out.map((e) => e.value).toList();
    }
    if (v is String) {
      try {
        final parsed = jsonDecode(v);
        return _images(parsed);
      } catch (_) {
        return [v];
      }
    }
    return const [];
  }

  factory Produit.fromJson(Map<String, dynamic> json) {
    final j = _unwrap(json);

    String? regionId = _s(j['regionId'] ?? j['region_id']);
    String? regionName;
    final regionObj = j['region'];
    if (regionObj is Map) {
      regionId ??= _s(regionObj['id']);
      regionName = _s(regionObj['nom'] ?? regionObj['name']);
    }
    regionName ??= _s(j['regionName'] ?? j['region_name']);

    final imgs = _images(j['images']);
    final firstFromApi = _s(j['firstImageUrl'] ?? j['first_image_url']);
    final compatImageUrl = _s(j['imageUrl'] ?? j['image_url']);

    return Produit(
      id: _s(j['id']) ?? '',
      nom: _s(j['nom']) ?? '',
      description: _s(j['description']),
      prix: _d(j['prix']),
      categorie: _s(j['categorie']),
      regionId: regionId,
      regionName: regionName,
      images: imgs,
      firstImageUrl: firstFromApi ?? (imgs.isNotEmpty ? imgs.first : compatImageUrl),
      imageUrl: compatImageUrl,
      statut: _s(j['statut']),
      vendeurId: _s(j['vendeurId'] ?? j['vendeur_id']),
      stock: _i(j['stock']),
      ratingAvg: _d(j['rating_avg'] ?? j['ratingAvg']),
      ratingCount: _i(j['rating_count'] ?? j['ratingCount']),
      artisan: _s(j['artisan']),
    );
  }

  Map<String, dynamic> toCreateBody() => {
    'nom': nom,
    if (description != null) 'description': description,
    if (prix != null) 'prix': double.parse((prix!).toStringAsFixed(2)),
    if (categorie != null) 'categorie': categorie,           // Habit | Plat | Accessoire
    if (regionId != null) 'regionId': regionId,
    if (imageUrl != null) 'imageUrl': imageUrl,              // fallback si pas encore endpoint images
    if (statut != null) 'statut': statut,
    if (vendeurId != null) 'vendeurId': vendeurId,
    if (stock != null) 'stock': stock,
    if (artisan != null) 'artisan': artisan,                 // champ UI
  };

  Map<String, dynamic> toUpdateBody() => toCreateBody();

  // copyWith pratique (utile dans l’admin)
  Produit copyWith({
    String? id,
    String? nom,
    String? description,
    double? prix,
    String? categorie,
    String? regionId,
    String? regionName,
    List<String>? images,
    String? firstImageUrl,
    String? imageUrl,
    String? statut,
    String? vendeurId,
    int? stock,
    double? ratingAvg,
    int? ratingCount,
    String? artisan,
  }) {
    return Produit(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      categorie: categorie ?? this.categorie,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      images: images ?? this.images,
      firstImageUrl: firstImageUrl ?? this.firstImageUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      statut: statut ?? this.statut,
      vendeurId: vendeurId ?? this.vendeurId,
      stock: stock ?? this.stock,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      artisan: artisan ?? this.artisan,
    );
  }
}

// Helpers UI <-> backend
String mapUiTypeToCategorie(String ui) {
  switch (ui) {
    case 'Plats': return 'Plat';
    case 'Tenues': return 'Habit';
    case 'Accessoires': return 'Accessoire';
    default: return 'Accessoire';
  }
}

String mapCategorieToUiType(String? cat) {
  switch (cat) {
    case 'Plat': return 'Plats';
    case 'Habit': return 'Tenues';
    case 'Accessoire': return 'Accessoires';
    default: return 'Accessoires';
  }
}

// Petits getters utiles en UI
extension ProduitUi on Produit {
  String get regionLabel => (regionName ?? regionId ?? '-');
  String get typeUi => mapCategorieToUiType(categorie);
  String get imageBest =>
      firstImageUrl ??
      imageUrl ??
      (images.isNotEmpty ? images.first : '');
  int get prixInt => (prix ?? 0).round();
  double get ratingSafe => (ratingAvg ?? 0).clamp(0, 5);
  int get likesSafe => ratingCount ?? 0;
}