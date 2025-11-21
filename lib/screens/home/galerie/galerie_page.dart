// Fichier: galerie_page.dart

import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/photo.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:malibots_challenge_eni/services/api_photo_service.dart';
import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';
import 'package:provider/provider.dart';

import 'photo_detail_page.dart'; // Assurez-vous d'importer la page de détail

class GaleriePage extends StatefulWidget {
  const GaleriePage({super.key});

  @override
  State<GaleriePage> createState() => _GaleriePageState();
}

class _GaleriePageState extends State<GaleriePage> {
  // 🚀 VARIABLES D'ÉTAT POUR L'API
  late Future<List<Photo>> _photosFuture;
  final PhotoApi _api = PhotoApi();

  // Note: La recherche et les filtres devront se faire sur la liste Photo.
  String selectedTheme = "Danse";
  String selectedSousTheme = "Tous";
  String searchQuery = "";

  final List<String> themes = ["Danse", "Mariage", "Baptême", "Événement"];
  final List<String> sousThemes = [
    "Tous",
    "Sonraï",
    "Bambara",
    "Tamacheq",
    "Dogon",
    "Minianka",
    "Malinké",
  ];

  // Remplacez la liste statique 'photos' par la liste dynamique 'allPhotos'
  List<Photo> allPhotos = [];

  @override
  void initState() {
    super.initState();
    _photosFuture = _loadPhotos();
  }

  // 🚀 Fonction de chargement des photos
  Future<List<Photo>> _loadPhotos() async {
    try {
      final photos = await _api.getPhotos();
      // On stocke la liste complète pour pouvoir la filtrer localement
      setState(() {
        allPhotos = photos;
      });
      return photos;
    } catch (e) {
      // Gérer l'erreur de chargement ici (Afficher un message à l'utilisateur)
      debugPrint("Erreur de chargement des photos: $e");
      rethrow;
    }
  }

  // 🚀 Utilise la liste dynamique 'allPhotos' pour le filtrage
  List<Photo> get filteredPhotos {
    if (allPhotos.isEmpty) return [];

    // NOTE: Pour le filtrage, nous faisons une supposition sur les champs de thème/sous-thème.
    // Idéalement, la régionId devrait servir de filtre. Ici, on filtre sur le titre.
    return allPhotos.where((photo) {
      // Pour une démo fonctionnelle, nous n'avons pas le champ theme/sousTheme dans le modèle Photo.
      // On filtre uniquement par recherche textuelle sur le titre.
      final matchSearch = photo.titre.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      // Les filtres theme/sousTheme statiques sont ici ignorés car les données API ne les contiennent pas.
      return matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Galerie Photos',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            // Les sélecteurs de thèmes sont conservés mais leur logique de filtrage API est à implémenter côté backend si nécessaire.
            _buildThemeSelector(),
            const SizedBox(height: 10),
            _buildSousThemeSelector(),
            const SizedBox(height: 10),
            // 🚀 FutureBuilder pour gérer l'état de chargement des données API
            Expanded(
              child: FutureBuilder<List<Photo>>(
                future: _photosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Erreur de chargement: ${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (filteredPhotos.isEmpty) {
                    return const Center(child: Text("Aucune photo trouvée."));
                  }
                  // Afficher la grille si les données sont chargées
                  return _buildPhotoGrid();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (val) => setState(() => searchQuery = val),
      decoration: decor(
        'Recherche',
      ).copyWith(prefixIcon: const Icon(Icons.search, color: Colors.brown)),
    );
  }

  // ... (Fonctions _buildThemeSelector, _buildSousThemeSelector non modifiées)
  Widget _buildThemeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Thème", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedTheme,
          dropdownColor: Colors.white,
          style: const TextStyle(color: AppColors.primary),
          items: themes
              .map(
                (theme) => DropdownMenuItem(value: theme, child: Text(theme)),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedTheme = val!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSousThemeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sousThemes.map((sous) {
          final isSelected = sous == selectedSousTheme;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(sous),
              selected: isSelected,
              selectedColor: Colors.brown,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.brown,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (_) {
                setState(() {
                  selectedSousTheme = sous;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // 🚀 Utilise la liste filtrée
  Widget _buildPhotoGrid() {
    return GridView.builder(
      itemCount: filteredPhotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return PhotoCard(photo: filteredPhotos[index]);
      },
    );
  }
}

// 🖼️ Widget PhotoCard (Adapté pour l'API)
class PhotoCard extends StatefulWidget {
  // 🚀 LE TYPE DE DONNÉE EST MAINTENANT LE MODÈLE Photo
  final Photo photo;
  const PhotoCard({super.key, required this.photo});

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  // Note: 'liked' est géré par FavoritesStore, pas besoin de state local ici.

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    // L'ID est directement disponible dans l'objet Photo
    final id = widget.photo.id;
    final isFav = store.isPhotoFavorite(id);

    // 🚀 Récupérer la première image (url)
    final imageUrl = widget.photo.images.isNotEmpty
        ? widget.photo.images.first.url
        : 'https://via.placeholder.com/150'; // Image par défaut

    // L'affichage de la première image doit être en Image.network

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // Le type de paramètre dans PhotoDetailPage est maintenant Photo
            builder: (context) => PhotoDetailPage(photo: widget.photo),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    // 🚀 CHANGEMENT: Image.asset devient Image.network
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Imprime les détails de l'erreur réseau dans la console
                        debugPrint(
                          '--- ERREUR CHARGEMENT IMAGE : $imageUrl ---',
                        );
                        debugPrint('Détail de l\'erreur : $error');
                        debugPrint('Stack Trace (optionnel) : $stackTrace');

                        // Retourne le widget d'erreur visible
                        return const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xB3000000),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 1.0,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: isFav ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
                              final wasFav = isFav;
                              // 🚀 Utiliser l'objet Photo directement
                              context.read<FavoritesStore>().togglePhoto(
                                widget.photo,
                              );

                              final text = wasFav
                                  ? 'Photo retirée des favoris'
                                  : 'Photo ajoutée aux favoris';
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(content: Text(text)));
                            },
                          ),
                          // ℹ️ Affichage statique du nombre de likes
                          const Text(
                            "10",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.photo.titre,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
