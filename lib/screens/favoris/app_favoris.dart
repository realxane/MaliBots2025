import 'dart:io';
import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/models/photo.dart';
import 'package:provider/provider.dart';

// Imports des modèles et stores
import 'package:malibots_challenge_eni/models/musique.dart'; // <--- Important pour le type Musique
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

// Imports des écrans de détail
import 'package:malibots_challenge_eni/screens/catalogue/app_produit_detail.dart';
import 'package:malibots_challenge_eni/screens/home/culture/conte_detail_page.dart';
import 'package:malibots_challenge_eni/screens/home/galerie/photo_detail_page.dart';
import 'package:malibots_challenge_eni/screens/musiques/music_player_screen.dart';

// Imports des widgets
import 'package:malibots_challenge_eni/widgets/favorite_product_tile.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  Color get brown => AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: brown,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Favoris',
            style: TextStyle(color: brown, fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            labelColor: brown,
            indicatorColor: brown,
            isScrollable: true, // Ajouté au cas où sur petits écrans
            tabs: const [
              Tab(text: 'Articles'),
              Tab(text: 'Musiques'),
              Tab(text: 'Proverbes'),
              Tab(text: 'Contes'),
              Tab(text: 'Galerie'),
            ],
          ),
        ),
        body: TabBarView(
          children: const [
            _ArticlesTab(),
            _MusiquesTab(), // Version corrigée ci-dessous
            _ProverbesTab(),
            _ContesTab(),
            _GalerieTab(),
          ],
        ),
      ),
    );
  }
}

// --- ONGLETS ---

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
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEDEDED)),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final p = items[i];
        final isFav = store.isProductFavorite(p.id);
        return FavoriteProductTile(
          product: p,
          isFavorite: isFav,
          onRemove: () => context.read<FavoritesStore>().removeProduct(p.id),
          onToggleFavorite: () =>
              context.read<FavoritesStore>().toggleProduct(p),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
            );
          },
        );
      },
    );
  }
}

// --- C'EST ICI QUE NOUS AVONS CORRIGÉ LA LOGIQUE MUSIQUE ---
class _MusiquesTab extends StatelessWidget {
  const _MusiquesTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();

    // Récupère la liste d'objets Musique depuis le store
    // Assurez-vous que dans favoris_store.dart votre getter s'appelle bien 'musicFavorites'
    final List<Musique> items = store.musicFavorites;

    if (items.isEmpty) return const _EmptyState();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEDEDED)),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final musique = items[i];

        // Vérifie si favori en utilisant l'objet Musique
        final isFav = store.isMusicFavoriteBy(musique);

        // Gestion Image (URL vs Asset placeholder)
        ImageProvider imgProvider;
        if (musique.urlImage != null && musique.urlImage!.isNotEmpty) {
          imgProvider = NetworkImage(musique.urlImage!);
        } else {
          imgProvider = const AssetImage('assets/images/music_placeholder.png');
        }

        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            backgroundImage: imgProvider,
            onBackgroundImageError:
                (_, __) {}, // Gestion silencieuse erreur image
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
            // Action toggle
            onPressed: () =>
                context.read<FavoritesStore>().toggleMusic(musique),
            tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
          ),
          onTap: () {
            // Navigation vers le lecteur avec la liste complète des favoris
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

class _ProverbesTab extends StatelessWidget {
  const _ProverbesTab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final items = store.proverbeFavorites;
    if (items.isEmpty) return const _EmptyState();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEDEDED)),
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
            style: TextStyle(color: Colors.brown.shade300),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.primary,
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

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEDEDED)),
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
            color: AppColors.primary,
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

    // 1. LE TYPE EST MAINTENANT List<Photo>
    final items = store.photoFavorites;

    if (items.isEmpty)
      return const _EmptyState(); // Assurez-vous que _EmptyState existe

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
        // 'p' est maintenant un objet de type Photo
        final p = items[i];

        // 2. L'ID est directement p.id (car FavoritesStore utilise maintenant l'ID de Photo)
        // Vous n'avez plus besoin d'appeler store.photoIdFrom(p)
        final id = p.id;

        // 3. Récupérer l'URL de la première image (nécessaire pour Image.network)
        final imageUrl = p.images.isNotEmpty
            ? p.images.first.url
            : 'https://via.placeholder.com/150'; // URL de secours

        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // 4. PLUS BESOIN DE Photo.fromJson(p) car 'p' est DÉJÀ un objet Photo
                    builder: (_) => PhotoDetailPage(photo: p),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // 5. CHANGEMENT: Image.asset devient Image.network
                child: Image.network(
                  imageUrl, // Utiliser l'URL de l'API
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
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  // 6. removePhoto utilise l'ID (p.id)
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // Assurez-vous que AppColors.primary est importé
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  // 7. Accéder au titre via l'attribut de l'objet Photo
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
