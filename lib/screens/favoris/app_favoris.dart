import 'dart:io';

import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_produit_detail.dart';
import 'package:malibots_challenge_eni/screens/home/culture/conte_detail_page.dart';
import 'package:malibots_challenge_eni/screens/home/galerie/photo_detail_page.dart';
import 'package:malibots_challenge_eni/screens/musiques/music_player_screen.dart';
import 'package:provider/provider.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:malibots_challenge_eni/widgets/favorite_product_tile.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  Color get brown => AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? cs.surface : Colors.white,
          foregroundColor: isDark ? cs.onSurface : brown,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Favoris',
            style: TextStyle(
              color: isDark ? cs.onSurface : brown,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            labelColor: isDark ? cs.primary : brown,
            unselectedLabelColor: isDark ? cs.onSurfaceVariant : null,
            indicatorColor: isDark ? cs.primary : brown,
            tabs: const [
              Tab(text: 'Articles'),
              Tab(text: 'Musiques'),
              Tab(text: 'Proverbes'),
              Tab(text: 'Contes'),
              Tab(text: 'Galerie'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ArticlesTab(),
            _MusiquesTab(),
            _ProverbesTab(),
            _ContesTab(),
            _GalerieTab(),
          ],
        ),
      ),
    );
  }
}

class _ArticlesTab extends StatefulWidget {
  const _ArticlesTab();
  @override
  State<_ArticlesTab> createState() => _ArticlesTabState();
}

class _ArticlesTabState extends State<_ArticlesTab> with AutomaticKeepAliveClientMixin {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // Déclenche un refresh uniquement si la liste locale est vide
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<FavoritesStore>();
      if (!_loaded && store.productFavorites.isEmpty) {
        _loaded = true;
        store.refreshProductFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final store = context.watch<FavoritesStore>();
    final items = store.productFavorites;

    if (store.loadingProducts && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (store.lastError != null && items.isEmpty) {
      return Center(child: Text('Erreur: ${store.lastError}'));
    }
    if (items.isEmpty) {
      return const _EmptyState();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sepColor = isDark ? theme.colorScheme.outlineVariant : const Color(0xFFEDEDED);

    return RefreshIndicator(
      onRefresh: () => context.read<FavoritesStore>().refreshProductFavorites(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        separatorBuilder: (_, __) => Divider(height: 1, color: sepColor),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final p = items[i];
          final isFav = store.isProductFavorite(p.id);
          return FavoriteProductTile(
            product: p,
            isFavorite: isFav,
            onRemove: () async {
              try {
                await context.read<FavoritesStore>().removeProductRemote(p.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${p.nom} retiré des favoris')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            onToggleFavorite: () async {
              try {
                final added = await context.read<FavoritesStore>().toggleProductRemote(p);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(added
                      ? '${p.nom} ajouté aux favoris'
                      : '${p.nom} retiré des favoris')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtle = isDark
        ? theme.colorScheme.onSurfaceVariant
        : Colors.brown.shade300;

    return Center(
      child: Text(
        'Aucun favori ici…',
        style: TextStyle(color: subtle),
      ),
    );
  }
}

class _ProverbesTab extends StatelessWidget {
  const _ProverbesTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final items = store.proverbeFavorites;
    if (items.isEmpty) return const _EmptyState();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final sepColor =
        isDark ? cs.outlineVariant : const Color(0xFFEDEDED);
    final subtle =
        isDark ? cs.onSurfaceVariant : Colors.brown.shade300;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) => Divider(height: 1, color: sepColor),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final p = items[i];
        final id = p['id'] ?? store.proverbeIdFrom(p);
        return ListTile(
          title: Text(p['texte'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(p['origine'] ?? '', style: TextStyle(color: subtle)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: isDark ? cs.primary : AppColors.primary,
            onPressed: () => context.read<FavoritesStore>().removeProverbe(id),
          ),
        );
      },
    );
  }
}

class _ContesTab extends StatelessWidget {
  const _ContesTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final items = store.conteFavorites;
    if (items.isEmpty) return const _EmptyState();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final sepColor =
        isDark ? cs.outlineVariant : const Color(0xFFEDEDED);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) => Divider(height: 1, color: sepColor),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final c = items[i];
        final id = c['id'] ?? store.conteIdFrom(c);
        return ListTile(
          title: Text(c['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(c['resume'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: isDark ? cs.primary : AppColors.primary,
            onPressed: () => context.read<FavoritesStore>().removeConte(id),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ConteDetailPage(conte: c)),
            );
          },
        );
      },
    );
  }
}

class _GalerieTab extends StatelessWidget {
  const _GalerieTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final items = store.photoFavorites;

    if (items.isEmpty) return const _EmptyState();

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, i) {
        final p = items[i];
        final id = store.photoIdFrom(p);
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PhotoDetailPage(photo: p)),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  p['images'][0],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () => context.read<FavoritesStore>().removePhoto(id),
                  tooltip: 'Retirer',
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p['titre'] ?? '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MusiquesTab extends StatelessWidget {
  const _MusiquesTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final items = store.musicFavorites;
    if (items.isEmpty) return const _EmptyState();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final sepColor =
        isDark ? cs.outlineVariant : const Color(0xFFEDEDED);
    final subtle =
        isDark ? cs.onSurfaceVariant : Colors.brown.shade300;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) => Divider(height: 1, color: sepColor),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final t = items[i];
        final id = store.musicIdFrom(t);
        final isFav = store.isMusicFavorite(id);

        ImageProvider imgProvider;
        final img = t['img'];
        if (img == null) {
          imgProvider = const AssetImage('assets/img_music_placeholder.jpg');
        } else if (img.toString().startsWith('assets/')) {
          imgProvider = AssetImage(img);
        } else {
          imgProvider = FileImage(File(img));
        }

        return ListTile(
          leading: CircleAvatar(backgroundImage: imgProvider, radius: 24),
          title: Text(t['title'] ?? 'Titre inconnu', maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            t['artist'] ?? 'Artiste inconnu',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: subtle),
          ),
          trailing: IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                color: isDark ? cs.primary : AppColors.primary),
            onPressed: () => context.read<FavoritesStore>().toggleMusic(t),
            tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MusicPlayerScreen(tracks: items, index: i),
              ),
            );
          },
        );
      },
    );
  }
}