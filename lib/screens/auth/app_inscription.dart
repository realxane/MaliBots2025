import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';

class InscriptionPage extends StatefulWidget {
   InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmController = TextEditingController();

  final TextEditingController _regionController = TextEditingController();

  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // Logo
          const Image(
            image: AssetImage(AppImages.logo),
            width: 90,
            height: 90,
          ),
              //const SizedBox(height: 10),
      
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
      
              const SizedBox(height: 20),
      
              Center(
                child: const Text("Inscrivez-vous", 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary
                  )),
              ),
      
                const SizedBox(height: 20),
      
              Center(
        child: Container(
          width: 350, // 🔹 largeur commune à tous les TextFields
          child: Column(
      mainAxisSize: MainAxisSize.min, // ne prend que la hauteur nécessaire
      children: [
        // Nom et prénom
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.text,
          decoration: decor('Nom et prénom'),
        ),
        const SizedBox(height: 10),
      
        // Email
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: decor('Email'),
        ),
        const SizedBox(height: 10),
      
        // Mot de passe
        TextField(
          controller: _passwordController,
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
        const SizedBox(height: 10),
      
        // Confirmation du mot de passe
        TextField(
          controller: _confirmController,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: Colors.white),
          decoration: decor('Confirmation du mot de passe').copyWith(
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      
        // Région
        TextField(
          controller: _regionController,
          keyboardType: TextInputType.text,
          decoration: decor('Région'),
        ),
      ],
          ),
        ),
      ),
      
              const SizedBox(height: 20),
      
              Center(
                child: Text("Qu'aimes-tu dans notre cultrure ?", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),),
              ),
      
              const SizedBox(height: 20),
      
               Center(
                 child: Wrap(
                  spacing: 20.0, // Espace horizontal entre les chips
                  runSpacing: 20.0, // Espace vertical entre les lignes de chips
                  children: <Widget>[
                    _buildCultureChip(context, 'Tenues', AppColors.primary),
                    _buildCultureChip(context, 'Accessoires', AppColors.primary),
                    _buildCultureChip(context, 'Cuisines', AppColors.primary),
                  ],
                ),
               ),
      
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 300,
                  child: bouton_large(
                    hint: "Suivant",
                    onPressed: (){
                      Navigator.pushNamed(context, AppRoutes.conditionsUtilisation);
                    }, 
                    ),
                ),
              )
        ],
      )
    );
  }
}

// Widget utilitaire pour les boutons de sélection (Chips)
  Widget _buildCultureChip(BuildContext context, String label, Color color) {
    return ActionChip(
      onPressed: () {
        // Logique de sélection/désélection
        
      },
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Rayon très arrondi
      ),
      elevation: 0,
    );
  }
