import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';

class BienvenueVendeur extends StatefulWidget {
  const BienvenueVendeur({super.key});

  @override
  State<BienvenueVendeur> createState() => _BienvenueVendeurState();
}

class _BienvenueVendeurState extends State<BienvenueVendeur> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.bienvenue_vendeur),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

          // --- Bouton suivant ou commencer
          Positioned(
            bottom: 30,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                
                  Navigator.pushReplacementNamed(context, AppRoutes.accueil);
              },
              child: Text(
               "Commencez à vendre",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}