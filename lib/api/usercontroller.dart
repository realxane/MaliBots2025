import 'dart:io';
import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/api/api_client.dart';
import 'package:malibots_challenge_eni/services/auth_storage.dart';

class ProfileController {
  final ApiClient _api = ApiClient();
  final AuthStorage _storage = AuthStorage();

  /// Modifier le profil de l'utilisateur connecté
  Future<Map<String, dynamic>> updateProfile({
    String? nom,
    File? image,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (nom != null) data['nom'] = nom;

      final response = await _api.postMultipart(
        '/user/update_profile',
        data,
        files: image != null ? {'image': image} : null,
      );

      // Retourne les infos mises à jour
      return {
        "success": true,
        "user": response['user'],
        "message": response['message'] ?? "Profil mis à jour avec succès",
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  /// Récupérer les informations du profil actuel
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _api.get('/me');
      return response;
    } catch (_) {
      return null;
    }
  }
}
