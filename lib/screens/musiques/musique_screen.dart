import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';
import 'playlist_screen.dart';

import 'package:malibots_challenge_eni/services/api_musique_service.dart';
import 'package:malibots_challenge_eni/models/musique.dart';

const Color bogolan = Color(0xFF7B3F00);
const Color background = Colors.white;

class MusiqueScreen extends StatefulWidget {
  const MusiqueScreen({super.key});

  @override
  State<MusiqueScreen> createState() => _MusiqueScreenState();
}

class _MusiqueScreenState extends State<MusiqueScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Données backend
  List<Musique> musiques = [];
  final api = MusiqueApi();
  bool isLoading = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    loadMusiques();
  }

  Future<void> loadMusiques() async {
    try {
      final fetchedMusiques = await api.getMusiques();
      setState(() {
        musiques = fetchedMusiques;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Erreur: $e");
      // Optionnel : Afficher une snackbar d'erreur
    }
  }

  // Récupérer les genres uniques (en gérant les nulls)
  List<Musique> getUniqueGenres() {
    final Map<String, Musique> uniqueMap = {};
    for (var zic in musiques) {
      String key = zic.genre ?? "Autre";

      if (!uniqueMap.containsKey(key)) {
        uniqueMap[key] = zic;
      }
    }
    return uniqueMap.values.toList();
  }

  // Récupérer les artistes uniques
  List<Musique> getUniqueArtists() {
    final Map<String, Musique> uniqueMap = {};
    for (var zic in musiques) {
      // artist n'est pas nullable dans notre modèle, donc pas d'erreur ici
      if (!uniqueMap.containsKey(zic.artist)) {
        uniqueMap[zic.artist] = zic;
      }
    }
    return uniqueMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final uniqueGenresList = getUniqueGenres();
    final uniqueArtistsList = getUniqueArtists();

    // Filtrage pour la recherche
    final filteredGenres = uniqueGenresList.where((m) {
      // CORRECTION 2: Gestion du null pour le toLowerCase()
      final genreName = m.genre ?? "Autre";
      return genreName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    final filteredArtists = uniqueArtistsList.where((m) {
      return m.artist.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Musique",
          style: TextStyle(
            color: bogolan,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: bogolan))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => query = val),
                    decoration: decor('genre musical, artiste...').copyWith(
                      prefixIcon: const Icon(Icons.search, color: Colors.brown),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Musique du Mali",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text("Découvrez les rythmes qui font vibrer le Mali."),
                  const SizedBox(height: 18),

                  // --- Section Genres ---
                  Row(
                    children: const [
                      Icon(Icons.music_note),
                      SizedBox(width: 6),
                      Text(
                        "Genres musicaux",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (filteredGenres.isEmpty)
                    const Center(child: Text("Aucun genre trouvé")),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: filteredGenres.map((musique) {
                      // CORRECTION 3: On sécurise le nom du genre
                      final genreTitle = musique.genre ?? "Autre";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaylistScreen(
                                categoryType: 'genre',
                                id: genreTitle,
                                title: genreTitle,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildImage(
                                  musique.urlImage,
                                ), // Appel fonction image sécurisée
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              genreTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // --- Section Artistes ---
                  const Text(
                    "Artistes populaires",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (filteredArtists.isEmpty)
                    const Text("Aucun artiste trouvé"),

                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredArtists.length,
                      itemBuilder: (_, i) {
                        final musique = filteredArtists[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlaylistScreen(
                                  categoryType: 'artiste',
                                  id: musique.artist,
                                  title: musique.artist,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.grey[200],
                                  // CORRECTION 4: Gestion image avatar sécurisée
                                  backgroundImage:
                                      (musique.urlImage != null &&
                                          musique.urlImage!.isNotEmpty)
                                      ? NetworkImage(musique.urlImage!)
                                      : const AssetImage(
                                              'assets/images/placeholder.png',
                                            )
                                            as ImageProvider,
                                  // Note: Assurez-vous d'avoir une image par défaut ou utilisez une Icone si l'image charge pas
                                  onBackgroundImageError: (_, __) {},
                                  child:
                                      (musique.urlImage == null ||
                                          musique.urlImage!.isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  musique.artist,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Fonction helper pour gérer l'affichage de l'image (Réseau ou Défaut)
  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.music_note, size: 30, color: Colors.grey),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.error, color: Colors.red)),
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
          ),
        );
      },
    );
  }
}
