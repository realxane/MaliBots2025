import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/musique.dart';
import 'package:malibots_challenge_eni/services/api_musique_service.dart';
import 'music_player_screen.dart';

const Color bogolan = Color(0xFF7B3F00);
const Color background = Colors.white;

class PlaylistScreen extends StatefulWidget {
  final String categoryType; // 'genre' ou 'artiste'
  final String id; // Le nom du genre ou de l'artiste
  final String title; // Le titre affiché

  const PlaylistScreen({
    super.key,
    required this.categoryType,
    required this.id,
    required this.title,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final api = MusiqueApi();

  // On stocke des objets Musique, pas des Maps
  List<Musique> filteredTracks = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadAndFilterMusiques();
  }

  Future<void> _loadAndFilterMusiques() async {
    try {
      // 1. Récupérer tout depuis le backend
      final allMusiques = await api.getMusiques();

      // 2. Filtrer selon le choix précédent (Genre ou Artiste)
      final results = allMusiques.where((m) {
        if (widget.categoryType == 'genre') {
          final genreA = (m.genre ?? '').toLowerCase();
          final genreB = widget.id.toLowerCase();
          return genreA == genreB;
        } else {
          // Recherche par artiste (contient le nom)
          return m.artist.toLowerCase().contains(widget.id.toLowerCase());
        }
      }).toList();

      setState(() {
        filteredTracks = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Erreur playlist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Filtrage local pour la barre de recherche (Search bar)
    final displayTracks = filteredTracks
        .where((t) => t.titre.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: bogolan))
          : Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher dans la playlist...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.textfieldcolor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                  ),
                ),

                Expanded(
                  child: displayTracks.isEmpty
                      ? const Center(
                          child: Text(
                            "Aucune musique trouvée",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.separated(
                          itemCount: displayTracks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final musique = displayTracks[index];

                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MusicPlayerScreen(
                                      tracks:
                                          displayTracks, // On passe la liste filtrée
                                      index:
                                          index, // L'index sur lequel on a cliqué
                                    ),
                                  ),
                                );
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildImage(musique.urlImage),
                              ),
                              title: Text(
                                musique.titre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                musique.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(
                                Icons.play_circle_fill,
                                size: 40,
                                color: bogolan,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Petite fonction pour gérer l'image réseau
  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return Image.asset(
        'assets/images/music_placeholder.png', // Assurez-vous d'avoir une image par défaut ou mettez une Icon
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey[300],
          width: 60,
          height: 60,
          child: const Icon(Icons.music_note),
        ),
      );
    }
    return Image.network(
      url,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
          child: const Icon(Icons.music_note),
        );
      },
    );
  }
}
