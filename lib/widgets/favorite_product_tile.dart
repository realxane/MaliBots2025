import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/product.dart';

class FavoriteProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;

  // NEW: callback de tap sur l’item
  final VoidCallback? onTap;

  const FavoriteProductTile({
    super.key,
    required this.product,
    required this.onRemove,
    required this.onToggleFavorite,
    required this.isFavorite,
    this.onTap,
  });

  Color get brown => AppColors.primary;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    final src = product.imageUrl;
    if (src.startsWith('http')) {
      imageWidget = Image.network(src, width: 78, height: 78, fit: BoxFit.cover);
    } else {
      imageWidget = Image.asset(src, width: 78, height: 78, fit: BoxFit.cover);
    }

    // Ajout de Material + InkWell pour le tap
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(6), child: imageWidget),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: TextStyle(fontWeight: FontWeight.w700, color: brown)),
                    const SizedBox(height: 6),
                    _Stars(rating: product.rating, color: Colors.amber),
                    const SizedBox(height: 6),
                    Text('Prix : ${product.price} F',
                        style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    tooltip: 'Supprimer',
                    icon: Icon(Icons.delete_outline, color: brown),
                    onPressed: onRemove,
                  ),
                  IconButton(
                    tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: brown,
                    ),
                    onPressed: onToggleFavorite,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating; // 0..5
  final Color color;
  const _Stars({required this.rating, required this.color});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) return Icon(Icons.star, color: color, size: 16);
        if (i == full && hasHalf) return Icon(Icons.star_half, color: color, size: 16);
        return Icon(Icons.star_border, color: color, size: 16);
      }),
    );
  }
}