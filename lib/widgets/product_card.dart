// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/product.dart';

class ProductCard extends StatelessWidget {
  final Produit product;
  final VoidCallback? onAdd;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onAdd, this.onTap});

  @override
  Widget build(BuildContext context) {
    final src = product.imageBest;
    final isUrl = src.startsWith('http');

    Widget img = isUrl
        ? Image.network(src, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]))
        : Image.asset(src, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(aspectRatio: 16 / 10, child: img),
                Positioned(
                  right: 8, bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('${product.likesSafe}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.nom, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${product.prixInt} FCFA', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(children: List.generate(5, (i) {
                        final r = product.ratingSafe;
                        if (i < r.floor()) return const Icon(Icons.star, color: Colors.amber, size: 16);
                        if (i < r) return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                        return const Icon(Icons.star_border, color: Colors.amber, size: 16);
                      })),
                    ]),
                    IconButton(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_circle, color: AppColors.textSecondary, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}