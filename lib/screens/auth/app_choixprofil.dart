import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';
import 'package:malibots_challenge_eni/widgets/buttons/carte_option_profil.dart';

class ChoixProfilPage extends StatelessWidget {
  const ChoixProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Navigator.canPop(context)
            ? fleche_retour(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.connecter);
                },
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                AppImages.logo, // <- fourni par vous
                height: 64,
              ),
              const SizedBox(height: 20),
              // Titre principal
              Text(
                'Bienvenue sur Anw ka Dambe !',
                textAlign: TextAlign.center,
                style: AppTextStyles.titre2,
              ),
              const SizedBox(height: 24),
              // Sous-titre
              Text('Choisissez votre profil', style: AppTextStyles.soustitre),
              const SizedBox(height: 20),

              // Carte Acheteur/Curieux culturel
              ProfileOptionCard(
                color: AppColors.textSecondary,
                hoverColor: AppColors.primary,
                icon: Icons.shopping_bag_outlined, // icône "acheteur"
                title: 'Acheteur/curieux culturel',
                subtitle:
                    'Pour découvrir les habits, les accessoires, et la culture malienne',
                onTap: () {
                  // Naviguez vers l’écran acheteur
                  Navigator.of(context).pushNamed(AppRoutes.inscrire);
                },
              ),
              const SizedBox(height: 14),

              // Carte Vendeur/Artisan
              ProfileOptionCard(
                color: AppColors.textSecondary,
                hoverColor: AppColors.primary,
                icon: Icons.storefront_outlined, // icône "vendeur/artisan"
                title: 'Vendeur/artisan',
                subtitle:
                    'Pour vendre votre création et partager votre savoir faire',
                onTap: () {
                  // Naviguez vers l’écran vendeur
                  Navigator.of(context).pushNamed(AppRoutes.inscrire_vendeur);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
