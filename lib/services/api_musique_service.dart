import 'dart:io';
import 'package:dio/dio.dart';
import '../models/musique.dart';

class MusiqueApi {
  // CLÉ 1: Utilisation de l'IP spéciale pour l'émulateur Android
  // Si vous utilisez un téléphone physique ou un navigateur, remplacez 10.0.2.2 par 192.168.1.35
  static const String BASE_IP = "192.168.1.35";

  final dio = Dio(
    BaseOptions(
      baseUrl: "http://$BASE_IP:8000/api", // Utilise l'IP corrigée
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  /// GET : Lister toutes les musiques
  Future<List<Musique>> getMusiques() async {
    final response = await dio.get('/musiques');

    if (response.statusCode == 200) {
      // CLÉ 2: Traitement de la réponse comme un List<dynamic> direct (pas besoin de la clé 'data')
      final List<dynamic> musiquesJson = response.data as List;

      return musiquesJson.map((e) => Musique.fromJson(e)).toList();
    } else {
      // Pour éviter que le cercle tourne sans fin en cas d'erreur serveur
      throw Exception(
        'Failed to load musiques. Status: ${response.statusCode}',
      );
    }
  }

  /// POST : Envoyer une musique (ADMIN)
  Future<bool> uploadMusique({
    required String titre,
    required String artist,
    required String genre,
    File? image,
    required File audio,
  }) async {
    final formData = FormData.fromMap({
      'titre': titre,
      'artist': artist,
      'genre': genre,
      if (image != null) 'image': await MultipartFile.fromFile(image.path),
      'audio': await MultipartFile.fromFile(audio.path),
    });

    final response = await dio.post('/musiques/admin', data: formData);

    return response.statusCode == 201;
  }

  /// DELETE : supprimer une musique
  Future<bool> deleteMusique(String id) async {
    final response = await dio.delete('/musiques/admin/$id');
    return response.statusCode == 200;
  }
}
