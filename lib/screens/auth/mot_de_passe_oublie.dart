import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String API_URL = 'http://192.168.1.35:8000/api';

class MotDePasseOublie extends StatefulWidget {
  const MotDePasseOublie({super.key});

  @override
  State<MotDePasseOublie> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<MotDePasseOublie> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Fonction pour envoyer l'email de réinitialisation
  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$API_URL/forgot-password'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'email': _emailController.text}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showFeedback(
          'Succès',
          body['message'] ??
              'Lien de réinitialisation envoyé avec succès. Vérifiez votre boîte de réception.',
          Colors.green,
        );
        _emailController.clear();
      } else if (response.statusCode == 404) {
        _showFeedback(
          'Erreur',
          body['message'] ?? 'Utilisateur introuvable.',
          Colors.red,
        );
      } else {
        // Autres erreurs de serveur (422 pour validation, 500, etc.)
        String errorMessage =
            body['message'] ??
            'Une erreur est survenue lors de l\'envoi du lien.';
        if (body['errors'] != null) {
          // Si Laravel renvoie des erreurs de validation (par exemple, email non valide)
          final errors = body['errors'] as Map<String, dynamic>;
          errorMessage += '\n' + errors.values.expand((e) => e).join('\n');
        }
        _showFeedback('Erreur', errorMessage, Colors.red);
      }
    } catch (e) {
      // Erreur de connexion (réseau)
      print('Erreur réseau/parsing: $e');
      _showFeedback(
        'Erreur Réseau',
        'Impossible de se connecter au serveur. Vérifiez votre connexion.',
        Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFeedback(String title, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFA65B45); // Couleur marron/ocre
    final Color buttonColor = const Color(0xFF6B3A2C); // Couleur du bouton

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Logo/Titre
              Center(
                child: Column(
                  children: [
                    // Remplacez 'assets/logo_appli.png' par le chemin réel de votre image
                    Image.asset('assets/images/logo_appli.png', height: 80),
                    const SizedBox(height: 5),
                    Text(
                      'Anw Ka Dembe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      'Découvrez l’âme du Mali',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 30),

              // Champ de saisie Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Entrez votre adresse email',
                  filled: true,
                  fillColor: primaryColor.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 20.0,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Format d\'email invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 50),

              // Bouton d'envoi
              ElevatedButton(
                onPressed: _isLoading ? null : _sendResetLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Envoyer le code VIS',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
