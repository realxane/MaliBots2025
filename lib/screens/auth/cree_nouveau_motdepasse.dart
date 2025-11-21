import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:malibots_challenge_eni/routes/app_routes.dart';

const String API_URL = 'http://10.236.139.37:8000/api';

final Color AppColorsPrimary = const Color(0xFFA65B45);
final Color AppColorsSecondary = const Color(0xFF6B3A2C);
const String AppImagesLogo = 'assets/images/logo_appli.png';

Widget fleche_retour({required VoidCallback onPressed}) => IconButton(
      icon: Icon(Icons.arrow_back, color: AppColorsPrimary),
      onPressed: onPressed,
    );

InputDecoration decor(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppColorsPrimary.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );

Widget bouton_large({
  required String hint,
  required VoidCallback onPressed,
}) =>
    ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsSecondary,
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        hint,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );

class AppTextStyles {
  static const TextStyle soustitre = TextStyle(color: Colors.grey);
}

class CreeNouveauMotdepasse extends StatefulWidget {
  final String token;
  final String email;

  const CreeNouveauMotdepasse({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<CreeNouveauMotdepasse> createState() =>
      _CreeNouveauMotdepasseState();
}

class _CreeNouveauMotdepasseState extends State<CreeNouveauMotdepasse> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newmotdepass = TextEditingController();
  final TextEditingController _newmotdepassconfirmation =
      TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$API_URL/reset-password'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'token': widget.token,
          'email': widget.email,
          'password': _newmotdepass.text,
          'password_confirmation': _newmotdepassconfirmation.text,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showFeedback(
          'Succès',
          body['message'] ?? 'Mot de passe réinitialisé avec succès !',
          Colors.green,
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.accueil,
          (route) => false,
        );
      } else {
        String errorMessage =
            body['message'] ?? 'Erreur lors de la réinitialisation.';
        if (body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          errorMessage += '\n${errors.values.expand((e) => e).join('\n')}';
        }
        _showFeedback('Erreur', errorMessage, Colors.red);
      }
    } catch (e) {
      debugPrint('Erreur réseau/parsing: $e');
      _showFeedback(
        'Erreur Réseau',
        'Impossible de se connecter au serveur.',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
  void dispose() {
    _newmotdepass.dispose();
    _newmotdepassconfirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taill_sreen = MediaQuery.of(context).size;
    final width = taill_sreen.width;
    final height = taill_sreen.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? fleche_retour(
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.08,
              vertical: height * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Logo + titre
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: height * 0.12,
                      width: height * 0.12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(AppImagesLogo),
                    ),
                    SizedBox(width: width * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Anw Ka Dembe",
                          style: TextStyle(
                            fontSize: width * 0.06,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.045),
                          child: Text(
                            "Découvrez l'âme du Mali",
                            style: AppTextStyles.soustitre.copyWith(
                              fontSize: width * 0.040,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: height * 0.06),

                Text(
                  "Créer un nouveau mot de passe",
                  style: TextStyle(
                    fontSize: 22,
                    color: AppColorsPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Entrez votre nouveau mot de passe pour sécuriser et accéder à votre compte. (Email: ${widget.email})",
                  style: AppTextStyles.soustitre.copyWith(
                    fontSize: width * 0.04,
                  ),
                ),

                SizedBox(height: height * 0.04),

                // Champ nouveau mot de passe
                TextFormField(
                  controller: _newmotdepass,
                  obscureText: _obscure1,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: decor("Nouveau mot de passe").copyWith(
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscure1 = !_obscure1),
                      icon: Icon(
                        _obscure1 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères.';
                    }
                    return null;
                  },
                ),

                SizedBox(height: height * 0.03),

                // Champ confirmation
                TextFormField(
                  controller: _newmotdepassconfirmation,
                  obscureText: _obscure2,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: Colors.white),
                  decoration:
                      decor("Confirmer le nouveau mot de passe").copyWith(
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscure2 = !_obscure2),
                      icon: Icon(
                        _obscure2 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _newmotdepass.text) {
                      return 'Les mots de passe ne correspondent pas.';
                    }
                    return null;
                  },
                ),

                SizedBox(height: height * 0.05),

                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColorsPrimary,
                          ),
                        )
                      : bouton_large(
                          hint: "Confirmer la réinitialisation",
                          onPressed: _resetPassword,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}