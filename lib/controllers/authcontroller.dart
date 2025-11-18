import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthController {
  final String baseUrl = "http://10.236.139.1:8000/api";

  /// Fonction login
  Future<Map<String, dynamic>> login({
    required String email,
    required String motDePasse,
  }) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      body: {
        "email": email,
        "motDePasse": motDePasse,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Retourne user, token et home_page
      return data;
    } else if (response.statusCode == 401) {
      throw Exception(data["message"] ?? "Identifiants invalides");
    } else if (response.statusCode == 422) {
      // Validation Laravel
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
