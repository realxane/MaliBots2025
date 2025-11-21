import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/models/photo.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/models/musique.dart'; // NOUVEL IMPORT

class FavoritesStore extends ChangeNotifier {
  // ====================================================================
  // 1. Favoris pour les produits (Articles = Habits, Plats, Accessoires)
  // ====================================================================
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

  // ====================================================================
  // 3. Galerie: favoris de photos
  // ====================================================================
  final List<Photo> _photoFavorites = [];

  // 2. CHANGER LE TYPE du getter
  List<Photo> get photoFavorites => List.unmodifiable(_photoFavorites);

  // 3. SUPPRIMER/MODIFIER photoIdFrom
  // Maintenant, l'ID est une propriété directe (photo.id), nous n'avons plus besoin
  // de créer une chaîne complexe à partir du titre et de l'image.
  // J'ai renommé cette méthode en getPhotoId pour clarifier qu'elle agit sur l'objet Photo.
  String getPhotoId(Photo photo) {
    // 💡 Utilisez l'ID unique retourné par l'API
    return photo.id;
  }

  // 4. Mettre à jour isPhotoFavorite (méthode interne)
  // Vérifie si un ID donné est dans la liste. C'est plus propre de le faire directement
  // en vérifiant l'ID sur les objets stockés.
  bool isPhotoFavorite(String photoId) {
    return _photoFavorites.any((p) => p.id == photoId);
  }

  // 5. Mettre à jour isPhotoFavoriteBy (vérifie si l'objet Photo est dans la liste)
  bool isPhotoFavoriteBy(Photo photo) {
    // <--- ACcepte Photo
    return isPhotoFavorite(getPhotoId(photo));
  }

  // 6. Mettre à jour togglePhoto
  void togglePhoto(Photo photo) {
    // <--- LE CHANGEMENT CRUCIAL : accepter Photo
    final id = getPhotoId(photo);

    if (isPhotoFavorite(id)) {
      removePhoto(id);
    } else {
      // 💡 On ajoute l'objet Photo, pas un Map
      _photoFavorites.add(photo);
      notifyListeners();
    }
  }

  // 7. Mettre à jour removePhoto
  void removePhoto(String photoId) {
    // On retire en comparant l'ID unique
    _photoFavorites.removeWhere((p) => p.id == photoId);
    notifyListeners();
  }

  void clearPhotoFavorites() {
    _photoFavorites.clear();
    notifyListeners();
  }
  // ====================================================================
  // 4. Favoris Musiques (Utilise le modèle Musique)
  // ====================================================================

  // CORRECTION : Utilise List<Musique>
  final List<Musique> _musicFavorites = [];

  // Le getter renvoie List<Musique>
  List<Musique> get musicFavorites => List.unmodifiable(_musicFavorites);

  // Méthode pour vérifier si une Musique est favorite
  bool isMusicFavoriteBy(Musique music) =>
      _musicFavorites.any((m) => m.id == music.id);

  // Méthode pour ajouter/supprimer une Musique
  void toggleMusic(Musique music) {
    final isExisting = isMusicFavoriteBy(music);
    if (isExisting) {
      _musicFavorites.removeWhere((m) => m.id == music.id);
    } else {
      _musicFavorites.add(music);
    }
    notifyListeners();
  }

  // Méthode pour supprimer par ID
  void removeMusic(String musicId) {
    _musicFavorites.removeWhere((m) => m.id == musicId);
    notifyListeners();
  }

  void clearMusicFavorites() {
    _musicFavorites.clear();
    notifyListeners();
  }
}
