import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String API_URL = 'http://192.168.1.35:8000/api';

const String AppRoutesAccueil =
    '/accueil'; // Placeholder pour AppRoutes.accueil

final Color AppColorsPrimary = const Color(0xFFA65B45);
final Color AppColorsSecondary = const Color(0xFF6B3A2C); // Couleur du bouton
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

Widget bouton_large({required String hint, required VoidCallback onPressed}) =>
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
  // Les arguments reçus par l'écran (token et email)
  final String token;
  final String email;

  const CreeNouveauMotdepasse({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<CreeNouveauMotdepasse> createState() => _CreeNouveauMotdepasseState();
}

class _CreeNouveauMotdepasseState extends State<CreeNouveauMotdepasse> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newmotdepass = TextEditingController();
  final TextEditingController _newmotdepassconfirmation =
      TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isLoading = false;

  // Fonction pour envoyer la réinitialisation de mot de passe
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          '$API_URL/reset-password',
        ), // Endpoint Laravel pour la réinitialisation
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'token': widget.token, // Le token reçu dans le lien
          'email': widget.email, // L'email reçu dans le lien
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
        // Redirection vers l'accueil ou l'écran de connexion après succès
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutesAccueil,
          (route) => false,
        );
      } else {
        // Erreurs de validation (422) ou autres erreurs serveur
        String errorMessage =
            body['message'] ?? 'Erreur lors de la réinitialisation.';
        if (body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          // Afficher toutes les erreurs de validation
          errorMessage += '\n' + errors.values.expand((e) => e).join('\n');
        }
        _showFeedback('Erreur', errorMessage, Colors.red);
      }
    } catch (e) {
      print('Erreur réseau/parsing: $e');
      _showFeedback(
        'Erreur Réseau',
        'Impossible de se connecter au serveur.',
        Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
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
                  Navigator.pop(context); // Retour à la page précédente
                },
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.08, // marge adaptative
              vertical: height * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Section Logo/Titre
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: height * 0.12,
                      width: height * 0.12,
                      // Ajout d'une simple icône si l'asset est manquant
                      child: Icon(
                        Icons.lock_open,
                        size: height * 0.08,
                        color: AppColorsPrimary,
                      ),
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
                          padding: EdgeInsets.only(left: 40),
                          child: Text(
                            "Découvrez l'âme du Mali",
                            style: AppTextStyles.soustitre.copyWith(
                              fontSize: width * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: height * 0.06),

                // Textes d'instructions
                Text(
                  "Créer un nouveau mot de passe",
                  style: TextStyle(
                    fontSize: 22,
                    color: AppColorsPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Entrez votre nouveau mot de passe pour sécuriser et accéder à votre compte. (Email: ${widget.email})",
                  style: AppTextStyles.soustitre.copyWith(
                    fontSize: width * 0.04,
                  ),
                ),
                SizedBox(height: height * 0.04),

                // Champ Nouveau Mot de passe
                TextFormField(
                  controller: _newmotdepass,
                  obscureText: _obscure1,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: decor("Nouveau mot de passe").copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
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

                // Champ Confirmation du mot de passe
                TextFormField(
                  controller: _newmotdepassconfirmation,
                  obscureText: _obscure2,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: Colors.white),
                  decoration: decor("Confirmer le nouveau mot de passe")
                      .copyWith(
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

                // Bouton de Confirmation
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
