import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/models/musique.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<Musique> tracks;
  final int index;

  const MusicPlayerScreen({
    super.key,
    required this.tracks,
    required this.index,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer player;
  late int currentIndex;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
    player = AudioPlayer();

    // Configuration des écouteurs
    player.onPositionChanged.listen((p) => setState(() => position = p));
    player.onDurationChanged.listen((d) => setState(() => duration = d));

    // Détecte le changement d'état (lecture, pause, arrêt)
    player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => isPlaying = s == PlayerState.playing);
    });

    // Détecte la fin de la lecture pour passer à la suivante
    player.onPlayerComplete.listen((_) {
      if (mounted) {
        next();
      }
    });

    // Lancer la lecture après le premier rendu pour garantir que l'AudioPlayer est prêt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      play();
    });
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes);
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  /// Lecture via URL (Backend)
  /// Lecture via URL (Backend)
  Future<void> play() async {
    await player.stop();
    setState(() {
      position =
          Duration.zero; // Réinitialise la position pour la nouvelle piste
    });

    final musique = widget.tracks[currentIndex];
    final url = musique.urlAudio;

    // AJOUT DE LA LIGNE DE DEBUG
    debugPrint('TENTATIVE DE LECTURE URL: $url');

    // VÉRIFICATION CRITIQUE DE L'URL
    if (url == null || url.isEmpty) {
      debugPrint(
        'Erreur: URL audio manquante ou invalide pour ${musique.titre}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: URL audio manquante pour cette musique.'),
          ),
        );
      }
      return;
    }

    try {
      // UrlSource est utilisé pour les chemins distants (HTTP/HTTPS)
      await player.play(UrlSource(url));
    } catch (e) {
      debugPrint('Erreur de lecture audio (Player exception): $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur de lecture : $e')));
      }
    }
  }

  Future<void> next() async {
    if (currentIndex < widget.tracks.length - 1) {
      setState(() => currentIndex++);
      await play();
    } else {
      // Revenir au début de la playlist si c'est la fin
      setState(() => currentIndex = 0);
      await play();
    }
  }

  Future<void> previous() async {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      await play();
    } else {
      // Revenir à la fin de la playlist si c'est le début
      setState(() => currentIndex = widget.tracks.length - 1);
      await play();
    }
  }

  @override
  void dispose() {
    // Il est crucial de disposer du lecteur pour libérer les ressources
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musique = widget.tracks[currentIndex];
    final store = context.watch<FavoritesStore>();

    // Utilise la méthode mise à jour du Store qui accepte l'objet Musique
    final isFav = store.isMusicFavoriteBy(musique);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          musique.titre,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // IMAGE JAQUETTE (Réseau)
          CircleAvatar(
            radius: 120,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                (musique.urlImage != null && musique.urlImage!.isNotEmpty)
                ? NetworkImage(musique.urlImage!)
                : null,
            child: (musique.urlImage == null || musique.urlImage!.isEmpty)
                ? const Icon(Icons.music_note, size: 80, color: Colors.grey)
                : null,
            onBackgroundImageError: (_, __) {
              // Gestion erreur image silencieuse
            },
          ),

          const SizedBox(height: 25),

          Text(
            musique.titre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            musique.artist,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),

          // BOUTON FAVORI
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.black54,
              size: 35,
            ),
            onPressed: () {
              context.read<FavoritesStore>().toggleMusic(musique);

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFav
                        ? 'Musique retirée des favoris'
                        : 'Musique ajoutée aux favoris',
                  ),
                  duration: const Duration(milliseconds: 900),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // SLIDER + DURÉE
          Column(
            children: [
              Slider(
                value: position.inSeconds.toDouble().clamp(
                  0,
                  duration.inSeconds.toDouble() + 1,
                ),
                max: duration.inSeconds.toDouble() + 1,
                activeColor: Colors.brown,
                onChanged: (value) {
                  player.seek(Duration(seconds: value.toInt()));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(position),
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      formatTime(duration),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // CONTRÔLES
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: previous,
                icon: const Icon(Icons.skip_previous, size: 45),
              ),
              IconButton(
                // Si en lecture -> Pause. Sinon -> Play
                onPressed: () => isPlaying ? player.pause() : play(),
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 75,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: next,
                icon: const Icon(Icons.skip_next, size: 45),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
