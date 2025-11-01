import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/screens/paiements/chargement.dart';

class WaveMoneyPayment extends StatefulWidget {
  final int montant;

  const WaveMoneyPayment({super.key, required this.montant});

  @override
  State<WaveMoneyPayment> createState() => _WaveMoneyPaymentState();
}

class _WaveMoneyPaymentState extends State<WaveMoneyPayment> {
  final TextEditingController _numeroController = TextEditingController();
  bool _isLoading = false;

  void _validerPaiement() async {
    final numero = _numeroController.text.trim();
    if (numero.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer votre numéro Wave Money")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simule l’envoi au backend
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Redirection vers la page "Paiement en cours"
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentProcessingScreen(totalAmount: 1000,),
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
        title: const Text('Paiement Wave Money', style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.primary)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, size: 30, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // "Entrez votre numéro Orange Money"
              const Text(
                "Entrez votre numéro Wave Money",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // TextField centré avec background chocolat et texte blanc
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _numeroController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Numéro Wave Money',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Montant à payer
              Text(
                "Montant à payer : ${widget.montant} F",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),

              // Bouton Payer maintenant
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : ElevatedButton(
                      onPressed: _validerPaiement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Payer maintenant",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
