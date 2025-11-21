import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/screens/paiements/reçu_paiemant.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String paiementId;
  final int totalAmount;

  const PaymentProcessingScreen({
    super.key,
    required this.paiementId,
    required this.totalAmount,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startCheckingPaiement();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // 🔄 Vérification automatique toutes les 3 secondes
  void _startCheckingPaiement() {
    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final response = await http.get(
          Uri.parse("http://192.168.0.108:8000/api/paiements/${widget.paiementId}"),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data["statut"] == "success") {
            timer.cancel();

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ReceiptPage(
                  paiementId: widget.paiementId,
                ),
              ),
            );
          }
        }
      } catch (e) {
        print("Erreur de vérification : $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paiement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),

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

            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 10,
            ),
            const SizedBox(height: 100),

            const Text(
              'Veuillez confirmer le paiement sur votre téléphone',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            Text(
              'Total: ${widget.totalAmount.toStringAsFixed(0)} F',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

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
              onPressed: () {},
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
