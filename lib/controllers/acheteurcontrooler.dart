import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:malibots_challenge_eni/models/uservendeur.dart';
String monip="10.236.139.1";
class Acheteurcontrooler {
 Future<Uservendeur> registeracheteur({
  required String nom,
  required String emailOrPhone,
  required String motdepasse,
  required String region,
  required String telephone,
}) async {
  final url = Uri.parse("http://10.236.139.1:8000/api/users/create/Acheteur");

  final response = await http.post(
    url,
    body: {
      "nom": nom,
      "email": emailOrPhone,
      "motDePasse": motdepasse,
      "region": region,
      "telephone": telephone,
    
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 201) {
    return Uservendeur.fromJson(data["user"]);
  } else {
    // Si c'est une erreur de validation
    if (data.containsKey("errors")) {
      final errors = (data["errors"] as Map<String, dynamic>)
          .entries
          .map((e) => "${e.key}: ${e.value.join(', ')}")
          .join("\n");
      throw Exception("${data["message"]}\n$errors");
    } else {
      // Autres erreurs
      throw Exception(data["message"] ?? "Erreur lors de l'inscription");
    }
  }
}

}
