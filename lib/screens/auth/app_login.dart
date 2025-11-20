import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/api/authencotrollerapi.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_social.dart';
import 'package:malibots_challenge_eni/widgets/buttons/text_button.dart';
import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true, _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(AppImages.logo, height: 64),
                const SizedBox(height: 16),

                Text( 
                  'Bienvenue sur Anw ka Dambe !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'connectez-vous',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 18),

                // Champ E-mail
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: decor('E-mail'),
                ),
                const SizedBox(height: 12),

                // Champ Mot de passe
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: Colors.white),
                  decoration: decor('Mot de passe').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: text_bouton(
                    hint: "Mot de passe oublié ?",
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Bouton Connexion
                SizedBox(
                  width: double.infinity,
                  child: bouton_large(

                    hint: "se connecter",
                  onPressed: () async {
  setState(() => _isLoading = true);

  try {
    final controller = AuthController();

    final result = await controller.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    // Vérifier si le login est OK
    if (result["success"] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["error"] ?? "Erreur inconnue")),
      );
      return;
    }

    // 👍 Login réussi
    final page = result["homePage"];

    if (page == "admin_dashboard") {
      Navigator.pushReplacementNamed(context, AppRoutes.admin_dash);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.accueil);
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

                  ),
                ),

                const SizedBox(height: 8),

                // Lien s'inscrire
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text(
                      "Vous n'avez pas de compte ?",
                      style: AppTextStyles.body.copyWith(fontSize: 15),
                    ),
                    text_bouton(
                      hint: "S'inscrire",
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.choixprofil);
                      },
                    ), 
                  ],
                ),

                const SizedBox(height: 8),

                // Séparateur "ou"
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ou'),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text('Se connecter avec', style: AppTextStyles.body),
                const SizedBox(height: 12),

                // Boutons sociaux
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialIconButton(
                      icon: FontAwesomeIcons.google,
                      color: Colors.red,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.authGoogleApple);
                      },
                    ),
                    const SizedBox(width: 16),
                    SocialIconButton(
                      icon: FontAwesomeIcons.apple,
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.authGoogleApple);
                      },
                    ),
                    const SizedBox(width: 16),
                    SocialIconButton(
                      icon: FontAwesomeIcons.facebook,
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.authGoogleApple);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
