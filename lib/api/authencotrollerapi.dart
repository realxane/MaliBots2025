import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';

import '../api/api_client.dart';
import '../services/auth_storage.dart';

class AuthController {
  final ApiClient _api = ApiClient();
  final AuthStorage _storage = AuthStorage();

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _api.post('/login', {
        'email': email,
        'motDePasse': password, // Même nom que dans Laravel
      });

      final token = response['token'];
      final user = response['user'];
      final homePage = response['home_page'];

      if (token == null) {
        throw Exception("Aucun token reçu");
      }

      // Sauvegarde du token
      await _storage.saveToken(token);

      // Sauvegarde du rôle si fourni par l'API (clés possibles adaptées)
      dynamic role;
      if (user is Map && user['role'] != null) {
        role = user['role'];
      } else if (response['role'] != null) {
        role = response['role'];
      } else if (response['data'] is Map) {
        final data = response['data'] as Map;
        if (data['user'] is Map && data['user']['role'] != null) role = data['user']['role'];
      }
      await _storage.saveRole(role?.toString());

      

      return {
        "success": true,
        "user": user,
        "homePage": homePage,
      };

    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  /// Déconnexion
  Future<void> logout(BuildContext context) async {
    try {
      await _api.post('/logout', {});
    await _storage.clear();
     Navigator.pushNamedAndRemoveUntil(context, AppRoutes.connecter, (route) => false);
    } catch (e) {
      // Affiche une erreur si le backend ne répond pas
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la déconnexion $e",)),
      );
    }

  }

  /// Récupérer le user connecté
  Future<Map<String, dynamic>?> me() async {
    try {
      final response = await _api.get('/me');
      return response;
    } catch (_) {
      return null;
    }
  }
}
