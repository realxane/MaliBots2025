import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:malibots_challenge_eni/services/auth_storage.dart';

class AuthController {
  final String baseUrl = "http://192.168.1.103:8000/api";
  final _storage = AuthStorage();

  Future<Map<String, dynamic>> login({
    required String email,
    required String motDePasse,
  }) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(url, body: {
      // si ton backend attend "password", renomme la clé ici:
      "email": email,
      "motDePasse": motDePasse,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Récupère le token quelle que soit la forme renvoyée
      final token = data['token'] ??
          data['access_token'] ??
          data['data']?['token'] ??
          data['data']?['access_token'];

      if (token == null || token.toString().trim().isEmpty) {
        throw Exception("Réponse login sans token.");
      }

      // Rôle si dispo (adapter la clé selon ton API)
      final role = data['user']?['role'] ??
          data['role'] ??
          data['data']?['user']?['role'];

      await _storage.saveToken(token.toString());
      await _storage.saveRole(role?.toString());

      return data is Map<String, dynamic> ? data : {"data": data};
    } else if (response.statusCode == 401) {
      throw Exception(data["message"] ?? "Identifiants invalides");
    } else if (response.statusCode == 422) {
      final errors = (data["errors"] as Map<String, dynamic>)
          .entries
          .map((e) => "${e.key}: ${e.value.join(', ')}")
          .join("\n");
      throw Exception(errors);
    } else {
      throw Exception(data["message"] ?? "Erreur serveur");
    }
  }
}