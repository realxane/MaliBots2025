import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';


class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pas d'AppBar visible dans l'image, on garde le corps centré
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
            // Titre de confirmation
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
            
            // Détails du reçu
            _buildDivider(),
            _buildReceiptDetail('Montant', '40000f'),
            _buildDivider(),
            _buildReceiptDetail('Frais', '100f'),
            _buildDivider(),
            _buildReceiptDetail('Montant Total', '40100f', isTotal: true),
            _buildDivider(),
            _buildReceiptDetail('Béneficiaire', 'Faso den gnouma', isDataBold: true),
            _buildDivider(),
            _buildReceiptDetail('Date', '10/10/2025', isDataBold: true),
            _buildDivider(),
            
            const SizedBox(height: 50),

            // Note de bas de page
            const Text(
              'Reçu géneré par anw ka Dambe',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Bouton "Fermer"
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.accueil);
                // Logique pour fermer la page (ex: Navigator.pop(context))
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
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

  // Widget utilitaire pour les lignes de détail du reçu
  Widget _buildReceiptDetail(String label, String value, {bool isTotal = false, bool isDataBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget utilitaire pour les séparateurs
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
