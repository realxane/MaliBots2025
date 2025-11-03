import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_produit_detail.dart';
import 'package:provider/provider.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:malibots_challenge_eni/widgets/favorite_product_tile.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  Color get brown => AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: brown,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Favoris', style: TextStyle(color: brown, fontWeight: FontWeight.w700)),
          bottom: TabBar(
            labelColor: brown,
            indicatorColor: brown,
            tabs: const [
              Tab(text: 'Articles'),
              Tab(text: 'Musiques'),
              Tab(text: 'Proverbes'),
              Tab(text: 'Contes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _ArticlesTab(),
            _EmptyTab(label: 'Musiques'),
            _EmptyTab(label: 'Proverbes'),
            _EmptyTab(label: 'Contes'),
          ],
        ),
      ),
    );
  }
}

class _ArticlesTab extends StatelessWidget {
  const _ArticlesTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final items = store.productFavorites;

    if (items.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEDEDED)),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final p = items[i];
        final isFav = store.isProductFavorite(p.id);
        return FavoriteProductTile(
          product: p,
          isFavorite: isFav,
          onRemove: () => context.read<FavoritesStore>().removeProduct(p.id),
          onToggleFavorite: () => context.read<FavoritesStore>().toggleProduct(p),

          // NEW: ouvre la page détail
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(
                  product: p,
                  // optionnel: passe des images ou couleurs si tu veux
                  // additionalImages: ['assets/images/xxx.jpg', 'https://...'],
                  // availableColors: [Colors.black, Colors.brown],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Aucun favori ici…',
        style: TextStyle(color: Colors.brown.shade300),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final String label;
  const _EmptyTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Aucun favori dans $label.',
        style: TextStyle(color: Colors.brown.shade300),
      ),
    );
  }
}