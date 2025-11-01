import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/screens/home/paiements/re%C3%A7u_paiemant.dart';

class PaymentProcessingScreen extends StatelessWidget {
  final double totalAmount;

  const PaymentProcessingScreen({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.grid_view, size: 30),
          onPressed: () {},
        ),
        title: const Text('Paiement', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, size: 30),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Texte "Paiement en cours"
            const Text(
              'Paiement en cours',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),

            // Cercle dynamique
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 10,
            ),
            const SizedBox(height: 100),

            // Instruction
            const Text(
              'Veuillez confirmer le paiement sur votre téléphone',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
    
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Montant
            Text(
              'Total: ${totalAmount.toStringAsFixed(0)} F',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
         SizedBox(height: 30),

            // Boutons centrés
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Annuler le paiement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ReceiptPage()));
                // Action Aide
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Aide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
