import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/screens/paiements/chargement.dart';
import 'package:malibots_challenge_eni/screens/paiements/PaiementController.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaveMoneyPayment extends StatefulWidget {
  final int montant;

  const WaveMoneyPayment({super.key, required this.montant});

  @override
  State<WaveMoneyPayment> createState() => _WaveMoneyPaymentState();
}

class _WaveMoneyPaymentState extends State<WaveMoneyPayment> {
  final TextEditingController _numeroController = TextEditingController();
  bool _isLoading = false;
  final paiementController = PaiementController();

 void _validerPaiement() async {
  final numero = _numeroController.text.trim();

  if (numero.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez entrer votre numéro Wave")),
    );
    return;
  }

  setState(() => _isLoading = true);

  paiementController.setMethode("Wave");
  paiementController.setInfos({
    "numero": numero,
    "montant": widget.montant,
  });

  try {
    final url = Uri.parse('https://192.168.0.108:8000/api/paiements');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ton_token_ici',
      },
      body: jsonEncode({
        "commande_id": paiementController.commandeId,
        "montant": widget.montant,
        "methode": "Wave",
        "infos": {"numero": numero},
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentProcessingScreen( paiementId: data["paiementId"],totalAmount: widget.montant),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la création du paiement")),
      );
    }
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erreur réseau")),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement Wave', style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.primary)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Entrez votre numéro Wave",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _numeroController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Numéro Wave',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Montant à payer : ${widget.montant} F",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : ElevatedButton(
                      onPressed: _validerPaiement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Payer maintenant",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
