import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
//import 'styles.dart';

class CondUtilisation extends StatefulWidget {
  const CondUtilisation({super.key});

  @override
  State<CondUtilisation> createState() => _CondUtilisationState();
}

class _CondUtilisationState extends State<CondUtilisation> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo
                  const Image(
                    image: AssetImage(AppImages.logo),
                    width: 90,
                    height: 90,
                  ),
                      const SizedBox(height: 10),
              
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
      
                const SizedBox(height: 40),

                // 2. Titre de la Page
                Center(
                  child: Text(
                    'Conditions d\'utilisations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Contenu des Conditions d'Utilisation
                Text(
                  "En accédant à Anw Ka Dambe, vous acceptez de respecter les principes et valeurs qui font la richesse de la culture malienne : respect, partage et authenticité. En créant un compte ou en vous connectant, vous vous engagez à :",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary, // Utilisation de primaryBrown pour le corps du texte
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                // Liste des engagements
                _buildBulletPoint("Utiliser la plateforme dans le respect des autres utilisateurs et de leurs créations ;"),
                _buildBulletPoint("Publier ou vendre uniquement des produits, œuvres ou contenus culturels conformes aux lois en vigueur et aux valeurs du Mali ;"),
                _buildBulletPoint("Ne pas diffuser de propos offensants, discriminatoires ou contraires à l'esprit communautaire d'Anw Ka Dambe ;"),
                _buildBulletPoint("Préserver la confidentialité de vos informations et de celles des autres membres ;"),
                _buildBulletPoint("Respecter les droits d'auteur, les traditions et les savoir-faire représentés sur la plateforme."),

                const SizedBox(height: 10),

                Text(
                  "Anw Ka Dambe se réserve le droit de suspendre ou supprimer tout compte ne respectant pas ces engagements, afin de garantir un espace sain, valorisant et fidèle à la culture malienne.",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // 4. Case à cocher "J'accepte"
                Row(
                  children: [
                    SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: Checkbox(
                        value: _isChecked,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _isChecked = newValue ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                        checkColor: Colors.white,
                        side: BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "J'accepte et je m'engage",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 5. Bouton "Créer un compte"
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isChecked
                        ? () {
                            // Logique de création de compte
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Compte en cours de création...')),
                            );
                          }
                        : null, // Désactiver le bouton si non coché
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0), // Rayon arrondi
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget utilitaire pour les points de liste
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Définition des couleurs personnalisées basées sur les images
const Color primaryBrown = Color(0xFF8B4513); // Marron foncé pour les boutons et le texte principal
const Color accentOrange = Color(0xFFB85C28); // Couleur d'accent pour les titres
const Color logoBlack = Colors.black;
const Color logoGrey = Colors.grey;
const Color white = Colors.white;

// Widget utilitaire pour les cercles du logo (simplifié)
Widget buildLogoCircle(Color color) {
  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}

// Widget pour la section Logo et Titre Principal
Widget buildHeaderSection() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      // Placeholder pour l'image/logo
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: logoBlack),
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Stack(
            children: [
              Positioned(top: 0, left: 0, child: buildLogoCircle(primaryBrown)),
              Positioned(top: 0, right: 0, child: buildLogoCircle(logoBlack)),
              Positioned(bottom: 0, left: 0, child: buildLogoCircle(logoBlack)),
              Positioned(bottom: 0, right: 0, child: buildLogoCircle(primaryBrown)),
              Center(child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: logoBlack, shape: BoxShape.circle))),
            ],
          ),
        ),
      ),
      const SizedBox(width: 15),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Anw ka Dambe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: logoBlack,
            ),
          ),
          Text(
            'Découvrez l\'âme du Mali',
            style: TextStyle(
              fontSize: 16,
              color: logoGrey,
            ),
          ),
        ],
      ),
    ],
  );
}

