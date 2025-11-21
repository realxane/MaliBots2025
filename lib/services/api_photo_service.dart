import 'dart:io';

import 'package:dio/dio.dart';

import '../models/photo.dart';
import '../models/region.dart';

class PhotoApi {
  static const String BASE_IP = "10.236.139.37";
  static const String API_BASE_URL = "http://$BASE_IP:8000/api";

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: API_BASE_URL,
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  /// GET : Lister toutes les publications de photos
  Future<List<Photo>> getPhotos() async {
    try {
      final response = await dio.get('/photos');
      if (response.statusCode == 200) {
        final List<dynamic> photosJson = response.data as List;
        return photosJson.map((e) => Photo.fromJson(e)).toList();
      } else {
        throw Exception(
          'Échec du chargement des photos. Statut: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Erreur de connexion à l\'API Photos: ${e.message}');
    }
  }

  /// GET : Lister une publication spécifique
  Future<Photo> getPhoto(String id) async {
    try {
      final response = await dio.get('/photos/$id');
      if (response.statusCode == 200) {
        return Photo.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Échec du chargement de la photo $id. Statut: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Erreur de connexion à l\'API Photo: ${e.message}');
    }
  }

  /// GET : Lister toutes les régions
  Future<List<Region>> getRegions() async {
    try {
      final response = await dio.get('/regions');
      if (response.statusCode == 200) {
        final List<dynamic> regionsJson = response.data as List;
        return regionsJson.map((e) => Region.fromJson(e)).toList();
      } else {
        throw Exception(
          'Échec du chargement des régions. Statut: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Erreur de connexion à l\'API Régions: ${e.message}');
    }
  }

  /// POST : Créer une publication avec images
  Future<Photo> storePhoto({
    required String titre,
    required String description,
    required String region,
    required List<File> images,
    String? publieParAdminId,
  }) async {
    final files = <MultipartFile>[];
    for (final imageFile in images) {
      files.add(
        await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      );
    }

    final formData = FormData.fromMap({
      'titre': titre,
      'description': description,
      'region': region,
      'publieParAdminId': publieParAdminId,
      'images[]': files,
    });

    try {
      final response = await dio.post('/photos/admin', data: formData);

      if (response.statusCode == 201) {
        return Photo.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Échec de la création. Statut: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Erreur de validation: ${e.response?.data}');
      }
      throw Exception('Erreur de connexion lors de la création: ${e.message}');
    }
  }

  /// POST : Mettre à jour
  Future<Photo> updatePhoto({
    required String id,
    String? titre,
    String? description,
    String? region,
    List<File>? newImages,
  }) async {
    final Map<String, dynamic> dataMap = {};

    if (titre != null) dataMap['titre'] = titre;
    if (description != null) dataMap['description'] = description;
    if (region != null) dataMap['region'] = region;

    if (newImages != null && newImages.isNotEmpty) {
      final files = <MultipartFile>[];
      for (final imageFile in newImages) {
        files.add(
          await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
        );
      }
      dataMap['images[]'] = files;
    }

    final formData = FormData.fromMap(dataMap);

    try {
      final response = await dio.post('/photos/admin/$id', data: formData);

      if (response.statusCode == 200) {
        return Photo.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Échec de la mise à jour. Statut: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Erreur de validation: ${e.response?.data}');
      }
      throw Exception(
        'Erreur de connexion lors de la mise à jour: ${e.message}',
      );
    }
  }

  /// DELETE : Supprimer une publication
  Future<void> destroyPhoto(String id) async {
    try {
      final response = await dio.delete('/photos/admin/$id');
      if (response.statusCode != 200) {
        throw Exception(
          'Échec de la suppression de la photo $id. Statut: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Erreur de connexion lors de la suppression: ${e.message}',
      );
    }
  }

  /// DELETE : Supprimer une image spécifique
  Future<void> deleteImage(String imageId) async {
    try {
      final response = await dio.delete('/photos/admin/image/$imageId');
      if (response.statusCode != 200) {
        throw Exception(
          'Échec de la suppression de l\'image $imageId. Statut: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Erreur de connexion lors de la suppression d\'image: ${e.message}',
      );
    }
  }
}