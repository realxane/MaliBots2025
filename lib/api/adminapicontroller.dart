import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:malibots_challenge_eni/api/api_client.dart';
import 'package:malibots_challenge_eni/config/app_config.dart';
import 'package:malibots_challenge_eni/services/auth_storage.dart';

class Adminapicontroller {
  final String baseUrl=AppConfig.apiBaseUrl;
  final api = ApiClient();
  final AuthStorage _auth = AuthStorage();

  /// Récupérer tous les utilisateurs
  
  /// Récupère tous les utilisateurs (Admin-only) final AuthStorage _auth = AuthStorage();

  Future<Map<String, dynamic>> getAllUsers() async {
    // si tu avais avant : prefs.getString('token'), tu n'en as plus besoin
    final res = await api.get('/admin/users'); // ton ApiClient gère le token
    return res;
  }
  /// Activer/désactiver un utilisateur
  Future<Map<String, dynamic>> toggleUserStatus(String id) async {
    final url = Uri.parse('$baseUrl/admin/users/toggle/$id');
    final response = await http.patch(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Impossible de changer le statut');
    }
  }

  /// Modifier le rôle d’un utilisateur
  Future<Map<String, dynamic>> updateUserRole(String id, String role) async {
    final url = Uri.parse('$baseUrl/admin/users/$id/role');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'role': role}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Impossible de changer le rôle');
    }
  }

  /// Filtrer par rôle
  Future<Map<String, dynamic>> getUsersByRole(String role) async {
    final resultat=api.get('/admin/user/$role');
    return resultat;
  }
}
