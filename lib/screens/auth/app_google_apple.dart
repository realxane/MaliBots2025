import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_social2.dart';

class AuthGoogleApple extends StatelessWidget {
  const AuthGoogleApple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                AppImages.logo,
                width: 90,
                height: 90,
              ),
              const SizedBox(height: 24),

              // Titre principal
              const Text(
                "Bienvenue sur Anw ka Dambe !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 32),

              // Sous-titre
              const Text(
                "Choisissez un compte pour continuer",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // // Bouton Google
              BoutonSocial2(
                color: AppColors.primary,
                icon: Image.asset(AppImages.googleLogo, width: 40, height: 40),
                title: "Continuer avec Google",
                subtitle: "Utiliser votre compte Google",
                onPressed: () {
                  // TODO: Ajoute la logique Google Sign-In
                },
              ),

              

              const SizedBox(height: 10),

              // Bouton Apple
              BoutonSocial2(
                color: const Color(0xFF8B3A1C),
                icon: Image.asset(AppImages.appleLogo, width: 40, height: 40),
                title: "Continuer avec Apple",
                subtitle: "Utiliser votre compte Apple",
                onPressed: () {
                  // TODO: Ajoute la logique Apple Sign-In
                },
              ),

              const SizedBox(height: 10),

              // Bouton facebook
              BoutonSocial2(
                color: const Color(0xFF8B3A1C),
                icon: Image.asset(AppImages.facebookLogo, width: 40, height: 40),
                title: "Continuer avec facebook",
                subtitle: "Utiliser votre compte facebook",
                onPressed: () {
                  // TODO: Ajoute la logique Apple Sign-In
                },
              ),

              const SizedBox(height: 16),

              // Ligne "ou"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.brown.shade300, thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("ou"),
                  ),
                  Expanded(child: Divider(color: Colors.brown.shade300, thickness: 1)),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                "J’ai déjà un compte ?",
                style: TextStyle(fontSize: 14, color: Colors.brown.shade700),
              ),

              const SizedBox(height: 8),

              // Bouton Se connecter
              SizedBox(
                  width: double.infinity,
                  child: bouton_large(
                    hint : "se connecter",
                    onPressed : (){
                      //Navigator.pushNamed(context, AppRoutes.AuthGoogleApple);
                    }
                    )
                ),

              const SizedBox(height: 32),

              // Lien s'inscrire
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.brown.shade700,
                  ),
                  children: [
                    const TextSpan(text: "Pas de compte ? "),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline, // ✅ aligne le texte
                      baseline: TextBaseline.alphabetic,        // ✅ sur la même ligne
                      child: InkWell(
                        onTap: () {
                          // TODO: Rediriger vers la page d’inscription
                        },
                        child: const Text(
                          "S’inscrire",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B3A1C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]
          ),

        ),
      )
    );
  }

   }
