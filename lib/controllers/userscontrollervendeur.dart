import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'; // debugPrint
import 'package:http/http.dart' as http;
import 'package:malibots_challenge_eni/models/uservendeur.dart';

class Userscontrollervendeur {
  // Mets la même baseUrl partout (ex: AppConfig.apiBaseUrl sans /api à la fin si tu concatènes /api ensuite)
  final String baseUrl = "http://10.236.139.1:8000";

  Future<Uservendeur> registervendeur({
    required String nom,
    required String email, // email exigé
    required String motdepasse,
    required String region,
    String? telephone,
    String? telephonePro,
    String? savoirFaire,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/create/Vendeur");

    http.Response response;
    try {
      response = await http
          .post(
            url,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "nom": nom,
              "email": email,
              "motDePasse": motdepasse,
              "region": region,
              if (telephone != null && telephone.isNotEmpty) "telephone": telephone,
              if (telephonePro != null && telephonePro.isNotEmpty) "telephone_pro": telephonePro,
              if (savoirFaire != null && savoirFaire.isNotEmpty) "descrit_ton_savoir_faire": savoirFaire,
            }),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw Exception("Délai dépassé lors de l’appel au serveur.");
    }

    debugPrint('POST $url -> ${response.statusCode}\n${response.body}');

    final raw = response.body.isEmpty ? '{}' : response.body;
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}

    if (response.statusCode == 201) {
      return Uservendeur.fromJson((data["user"] ?? {}) as Map<String, dynamic>);
    }

    if (response.statusCode == 422 && data.containsKey('errors')) {
      final errors = (data["errors"] as Map<String, dynamic>)
          .entries
          .map((e) => "${e.key}: ${(e.value as List).join(', ')}")
          .join("\n");
      final msg = data["message"]?.toString() ?? "Erreur de validation";
      throw Exception("$msg\n$errors");
    }

    final details = [
      if (data['message'] != null) data['message'].toString(),
      if (data['error'] != null) data['error'].toString(),
      if (data.isEmpty && response.body.isNotEmpty) response.body,
    ].where((e) => e.trim().isNotEmpty).join(' — ');

    throw Exception(details.isNotEmpty ? details : "Erreur serveur (${response.statusCode})");
  }
}