import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/screens/paiements/orange.dart';
import 'package:malibots_challenge_eni/screens/paiements/wave.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;

  // Widget pour un bouton de mode de paiement
  Widget _buildPaymentButton({
    required String title,
    required String value,
    String? subtitle,
  }) {
    final bool isSelected = _selectedPaymentMethod == value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPaymentMethod = value;
            if (value == 'orange_money') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OrangeMoneyPaymentPage(montant: 10000)));
            }
            if (value == 'wave') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WaveMoneyPayment(montant: 20000)));
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          minimumSize: const Size(double.infinity, 60),
          elevation: 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.grid_view, size: 30, color: AppColors.primary),
          onPressed: () {},
        ),
        title: const Text('Payement', style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.primary)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, size: 30, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Titre principal
            Text(
              'Choix du mode de payement',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Informations de commande
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text('Articles : 13', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold) ),
                  const SizedBox(height: 8),
                  Text('Total: 40000f', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold) ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Sous-titre de sélection
            Text(
              'Selectionner le mode de payement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Boutons de mode de paiement
            _buildPaymentButton(
              title: 'Orange Money',
              value: 'orange_money',
            ),
            _buildPaymentButton(
              title: 'Wave',
              value: 'wave',
            ),
            _buildPaymentButton(
              title: 'Carte bancaire',
              value: 'carte_bancaire',
              subtitle: 'VISA/mastercard',
            ),
          ],
        ),
      ),
    );
  }
}
