import 'package:flutter/material.dart';
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
  bool _obscure = true;


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
                Image.asset(
                  AppImages.logo, 
                  height: 64,
                ),
                const SizedBox(height: 16),

                Text(
                  'Bienvenue sur Anw ka Dambe !',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titre2,
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
                //champ E-mail
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: decor('E-mail'),
                ),
                const SizedBox(height: 12),
                //champ Mot de passe
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
                    hint : "Mot de passe oublié ?",
                    onPressed: (){
                      
                    }
                    )
                ),

                const SizedBox(height: 4),

                // Bouton Connexion
                SizedBox(
                  width: double.infinity,
                  child: bouton_large(
                    hint : "se connecter",
                    onPressed : (){
                      Navigator.pushNamed(context, AppRoutes.choixprofil);
                    }
                    )
                ),

                const SizedBox(height: 8),

                // Lien s'inscrire
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Vous n'avez pas de compte ?"),
                    text_bouton(
                      hint: "S'inscrire",
                      onPressed: () {

                      }
                      )
                  ],
                ),

                const SizedBox(height: 8),

                // Séparateur "ou"
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ou'),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text('Se connecter avec'),
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