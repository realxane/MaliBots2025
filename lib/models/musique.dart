// Fichier : model/musique.dart

import 'package:malibots_challenge_eni/services/api_musique_service.dart';

class Musique {
  final String id;
  final String titre;
  final String artist;
  final String? genre;
  final String? urlImage;
  final String urlAudio;

  Musique({
    required this.id,
    required this.titre,
    required this.artist,
    this.genre,
    this.urlImage,
    required this.urlAudio,
  });

  factory Musique.fromJson(Map<String, dynamic> json) {
    // Utilisez l'IP définie dans le service (10.0.2.2 ou 192.168.1.35)
    // IMPORTANT : Changez la ligne suivante si vous n'êtes pas sur un émulateur Android !
    const String mediaIp = MusiqueApi.BASE_IP; // Récupère 10.0.2.2

    // Fonction pour corriger l'URL en remplaçant 127.0.0.1 par l'IP correcte
    String? correctUrl(String? url) {
      if (url == null) return null;
      return url.replaceFirst('127.0.0.1', mediaIp);
    }

    return Musique(
      id: json['id'].toString(), // S'assurer que l'ID est une String
      titre: json['titre'],
      artist: json['artist'],
      genre: json['genre'],
      // CLÉ 3: Correction de l'URL pour l'image
      urlImage: correctUrl(json['urlImage']),
      // CLÉ 3: Correction de l'URL pour l'audio
      urlAudio: correctUrl(json['urlAudio'])!,
    );
  }
}
