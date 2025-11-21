import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';

class ReceiptPage extends StatefulWidget {
  final String paiementId;

  const ReceiptPage({super.key, required this.paiementId});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  Map<String, dynamic>? paiement;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPaiementData();
  }

  Future<void> _loadPaiementData() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/paiements/${widget.paiementId}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          paiement = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("Erreur reçu : $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (paiement == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Erreur : Paiement introuvable",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    final montant = paiement!["montant"] ?? 0;
    final frais = montant*0.10;
    final total = montant + frais;
    final beneficiaire = paiement!["referenceFournisseur"] ?? "—";
    final date = paiement!["created_at"] ?? "—";

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Logo
            Center(
              child: Image.asset(
                AppImages.logo,
                height: 64,
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            const Text(
              'Paiement validé',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),

            // Détails
            _buildDivider(),
            _buildReceiptDetail('Montant', '$montant F'),
            _buildDivider(),
            _buildReceiptDetail('Frais', '$frais F'),
            _buildDivider(),
            _buildReceiptDetail('Montant Total', '$total F', isTotal: true),
            _buildDivider(),
            _buildReceiptDetail('Bénéficiaire', beneficiaire, isDataBold: true),
            _buildDivider(),
            _buildReceiptDetail('Date', date, isDataBold: true),
            _buildDivider(),

            const SizedBox(height: 50),

            // Note
            const Text(
              'Reçu généré par anw ka Dambe',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 50),

            // Bouton Fermer
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.accueil);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 50.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Fermer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Ligne du reçu
  Widget _buildReceiptDetail(String label, String value,
      {bool isTotal = false, bool isDataBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: isTotal ? 18 : 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Séparateur
  Widget _buildDivider() {
    return const Divider(
      color: AppColors.primary,
      height: 1,
      thickness: 0.5,
      indent: 10,
      endIndent: 10,
    );
  }
}
