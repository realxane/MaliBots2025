import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/musique.dart';
import 'package:malibots_challenge_eni/models/photo.dart';
import 'package:malibots_challenge_eni/models/product.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_produit_detail.dart';
import 'package:malibots_challenge_eni/screens/home/culture/conte_detail_page.dart';
import 'package:malibots_challenge_eni/screens/home/galerie/photo_detail_page.dart';
import 'package:malibots_challenge_eni/screens/musiques/music_player_screen.dart';
import 'package:malibots_challenge_eni/widgets/favorite_product_tile.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  Color get brown => AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final canPop = Navigator.of(context).canPop();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? cs.surface : Colors.white,
          foregroundColor: isDark ? cs.onSurface : brown,
          elevation: 0.5,
          leading: canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null,
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
            isScrollable: true,
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

// ---------- Onglet ARTICLES ----------

class _ArticlesTab extends StatefulWidget {
  const _ArticlesTab();

  @override
  State<_ArticlesTab> createState() => _ArticlesTabState();
}

class _ArticlesTabState extends State<_ArticlesTab>
    with AutomaticKeepAliveClientMixin {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
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
    final List<Produit> items = store.productFavorites;

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
    final sepColor =
        isDark ? theme.colorScheme.outlineVariant : const Color(0xFFEDEDED);

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
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${p.nom} retiré des favoris')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            onToggleFavorite: () async {
              try {
                final added =
                    await context.read<FavoritesStore>().toggleProductRemote(p);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      added
                          ? '${p.nom} ajouté aux favoris'
                          : '${p.nom} retiré des favoris',
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: p),
                ),
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

// ---------- Onglet MUSIQUES (modèle Musique) ----------

class _MusiquesTab extends StatelessWidget {
  const _MusiquesTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final List<Musique> items = store.musicFavorites;

    if (items.isEmpty) return const _EmptyState();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEDEDED)),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final musique = items[i];
        final isFav = store.isMusicFavoriteBy(musique);

        ImageProvider imgProvider;
        if (musique.urlImage != null && musique.urlImage!.isNotEmpty) {
          imgProvider = NetworkImage(musique.urlImage!);
        } else {
          imgProvider =
              const AssetImage('assets/images/music_placeholder.png');
        }

        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            backgroundImage: imgProvider,
            onBackgroundImageError: (_, __) {},
            child: (musique.urlImage == null || musique.urlImage!.isEmpty)
                ? const Icon(Icons.music_note, color: Colors.grey)
                : null,
          ),
          title: Text(
            musique.titre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            musique.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.brown.shade300),
          ),
          trailing: IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: AppColors.primary,
            ),
            onPressed: () =>
                context.read<FavoritesStore>().toggleMusic(musique),
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

// ---------- Onglet PROVERBES ----------

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
    final sepColor = isDark ? cs.outlineVariant : const Color(0xFFEDEDED);
    final subtle = isDark ? cs.onSurfaceVariant : Colors.brown.shade300;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) => Divider(height: 1, color: sepColor),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final p = items[i];
        final id = p['id'] ?? store.proverbeIdFrom(p);
        return ListTile(
          title: Text(
            p['texte'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            p['origine'] ?? '',
            style: TextStyle(color: subtle),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: isDark ? cs.primary : AppColors.primary,
            onPressed: () =>
                context.read<FavoritesStore>().removeProverbe(id),
          ),
        );
      },
    );
  }
}

// ---------- Onglet CONTES ----------

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
    final sepColor = isDark ? cs.outlineVariant : const Color(0xFFEDEDED);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) => Divider(height: 1, color: sepColor),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final c = items[i];
        final id = c['id'] ?? store.conteIdFrom(c);
        return ListTile(
          title: Text(
            c['titre'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            c['resume'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: isDark ? cs.primary : AppColors.primary,
            onPressed: () => context.read<FavoritesStore>().removeConte(id),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ConteDetailPage(conte: c),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------- Onglet GALERIE ----------

class _GalerieTab extends StatelessWidget {
  const _GalerieTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final List<Photo> items = store.photoFavorites;

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
        final id = p.id;
        final imageUrl = p.images.isNotEmpty
            ? p.images.first.url
            : 'https://via.placeholder.com/150';

        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PhotoDetailPage(photo: p),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
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
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () =>
                      context.read<FavoritesStore>().removePhoto(id),
                  tooltip: 'Retirer',
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p.titre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------- Empty state ----------

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