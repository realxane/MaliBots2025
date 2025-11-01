import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/product.dart';


final Color _brown = AppColors.textSecondary;
class ProductReviewPage extends StatelessWidget {
  final Product product;
  final String statusText;
  const ProductReviewPage({super.key, required this.product, required this.statusText});

  @override
  Widget build(BuildContext context) {
    final priceText = '${product.price.toString()} FCFA';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(product.name),
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
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image_outlined, color: _brown.withOpacity(.6), size: 48),
                  ),
                ),
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
                      _labelValue('Nom', product.name),
                      const SizedBox(height: 8),
                      _labelValue(
                      'Description',
                      'Type: ${product.type} • Région: ${product.region}\n'
                      'Prix: $priceText',
                      ),
                      
                      const SizedBox(height: 8),
                      _labelValue('Auteur', product.artisan),
                      const SizedBox(height: 8),
                      _labelValue('Date', statusText.replaceFirst('En attente ', '')),
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
                  onPressed: () {
                    Navigator.pop(context, 'rejected');
                  },
                  child: const Text('Rejeter'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textSecondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context, 'approved');
                  },
                  child: const Text('Approuver'),
                ),
              ],
            ),
          ],
        ),
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