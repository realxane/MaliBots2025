import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'music_player_screen.dart';

const Color bogolan = Color(0xFF7B3F00);
//const Color background = Color(0xFFD2B48C);
const Color background = Colors.white;

class PlaylistScreen extends StatefulWidget {
  final String categoryType;
  final String id;
  final String title;

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
  final Map<String, List<Map<String, String>>> fakeLibrary = {
    'bambara': [
      {
        'title': 'Bambara Song 1',
        'path': 'assets/musics/bambara/track1.mp3',
        'img': 'assets/musics/bambara/track1.jpg',
      },
      {
        'title': 'Bambara Song 2',
        'path': 'assets/musics/bambara/track2.mp3',
        'img': 'assets/musics/bambara/track2.jpg',
      },
    ],
    'songhoy': [
      {
        'title': 'Baba Salah',
        'path': 'assets/musics/songhoy/track1.mp3',
        'img': 'assets/musics/songhoy/songhoy.jpg',
      },
      {
        'title': 'Ibrahim Hama Maiga',
        'path': 'assets/musics/songhoy/track2.mp3',
        'img': 'assets/musics/songhoy/songhoy.jpg',
      },
      {
        'title': 'Baba Salah',
        'path': 'assets/musics/songhoy/track4.mp3',
        'img': 'assets/musics/songhoy/track2.jpg',
      },
      {
        'title': 'Fissa Maiga',
        'path': 'assets/musics/songhoy/track3.mp3',
        'img': 'assets/musics/songhoy/songhoy.jpg',
      },
      {
        'title': 'Baba Salah',
        'path': 'assets/musics/songhoy/track5.mp3',
        'img': 'assets/musics/songhoy/track2.jpg',
      },
      {
        'title': 'Aly farka touré',
        'path': 'assets/musics/songhoy/Ali_Farka_Toure.mp3',
        'img': 'assets/musics/songhoy/songhoy.jpg',
      },
      {
        'title': 'DOUMMA_MAIGA_TAKAMBA',
        'path': 'assets/musics/songhoy/DOUMMA_MAIGA_TAKAMBA.mp3',
        'img': 'assets/musics/songhoy/songhoy.jpg',
      },
      {
        'title': 'Leyla Gobi',
        'path': 'assets/musics/songhoy/LEÏLA.mp3',
        'img': 'assets/musics/songhoy/songhoy.jpg',
      },
      {
        'title': 'Baba_Salah__-_Tugu_Tugu',
        'path': 'assets/musics/songhoy/Baba_Salah__-_Tugu_Tugu.mp3',
        'img': 'assets/musics/songhoy/track2.jpg',
      },
      {
        'title': 'AIGNA',
        'path': 'assets/musics/songhoy/AIGNA.MP3',
        'img': 'assets/musics/songhoy/songhoy.jpg',
      },
    ],
    'aly': [
      {
        'title': 'Aly Track 1',
        'path': 'assets/musics/bambara/track1.mp3',
        'img': 'assets/musics/bambara/track1.jpg',
      },
    ],
    'oumou': [
      {
        'title': 'Oumou sangaré',
        'path': 'assets/musics/bambara/Oumou_Sangare_-_Wayeina.mp3',
        'img': 'assets/musics/bambara/track1.jpg',
      },
      {
        'title': 'Diarabi nene',
        'path': 'assets/musics/bambara/Oumou_Sangaré_-_Diaraby_Nene.mp3',
        'img': 'assets/musics/bambara/track1.jpg',
      },
    ],
  };

  late List<Map<String, String>> tracks;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    tracks = fakeLibrary[widget.id] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final filteredTracks = tracks
        .where(
          (t) => t['title']!.toLowerCase().contains(searchQuery.toLowerCase()),
        )
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

      body: Column(
        children: [
          //  Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher artiste ou titre...",
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
            child: filteredTracks.isEmpty
                ? const Center(
                    child: Text(
                      "Aucun résultat",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredTracks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final track = filteredTracks[index];

                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MusicPlayerScreen(
                                tracks: filteredTracks,
                                index: index,
                              ),
                            ),
                          );
                        },

                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            track['img']!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),

                        title: Text(
                          track['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
}
