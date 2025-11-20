import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/product.dart';

final Color _brown = AppColors.textSecondary;

class ProductReviewPage extends StatelessWidget {
  final Produit product;
  final String statusText;

  const ProductReviewPage({
    super.key,
    required this.product,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final String priceText = '${product.prixInt} FCFA';

    // Meilleure image dispo (firstImageUrl -> imageUrl -> images -> '')
    final String img = product.imageBest;
    final bool hasImg = img.isNotEmpty;
    final bool isNetwork = hasImg && (img.startsWith('http://') || img.startsWith('https://'));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(product.nom),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: hasImg
                    ? (isNetwork
                        ? Image.network(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageError(),
                          )
                        : Image.asset(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageError(),
                          ))
                    : _imageError(),
              ),
            ),
            const SizedBox(height: 16),

            // Infos
            Expanded(
              child: SingleChildScrollView(
                child: DefaultTextStyle(
                  style: TextStyle(color: _brown, fontSize: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelValue('Nom', product.nom),
                      const SizedBox(height: 8),
                      // Description brute si fournie
                      if ((product.description ?? '').trim().isNotEmpty) ...[
                        _labelValue('Description', product.description!.trim()),
                        const SizedBox(height: 8),
                      ],
                      // Détails UI-friendly via l’extension ProduitUi
                      _labelValue(
                        'Détails',
                        'Type: ${product.typeUi} • Région: ${product.regionLabel}\n'
                        'Prix: $priceText',
                      ),
                      const SizedBox(height: 8),
                      _labelValue('Artisan', product.artisan ?? '—'),
                      const SizedBox(height: 8),
                      _labelValue('Statut', statusText),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context, 'rejected'),
                  child: const Text('Rejeter'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textSecondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context, 'approved'),
                  child: const Text('Approuver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageError() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: _brown.withOpacity(.6),
        size: 48,
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              color: _brown,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: _brown.withOpacity(.9))),
      ],
    );
  }
}