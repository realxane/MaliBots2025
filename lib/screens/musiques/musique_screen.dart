import 'package:flutter/material.dart';
import 'playlist_screen.dart';

const Color bogolan = Color(0xFF7B3F00);
// const Color background = Color(0xFFD2B48C);
const Color background = Colors.white;

class MusiqueScreen extends StatefulWidget {
  const MusiqueScreen({super.key});

  @override
  State<MusiqueScreen> createState() => _MusiqueScreenState();
}

class _MusiqueScreenState extends State<MusiqueScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> genres = [
    {
      'id': 'bambara',
      'title': 'Bambara',
      'img': 'assets/musics/bambara/bambara.jpg',
    },
    {
      'id': 'songhoy',
      'title': 'Songhoy',
      'img': 'assets/musics/songhoy/songhoy.jpg',
    },
    {
      'id': 'tamasheq',
      'title': 'Tamasheq',
      'img': 'assets/musics/tamasheq/tamasheq.jpg',
    },
    {'id': 'dogon', 'title': 'Dogon', 'img': 'assets/musics/dogon/dogon.jpg'},
    {
      'id': 'soninke',
      'title': 'Soninké',
      'img': 'assets/musics/soninke/soninke.jpg',
    },
    {
      'id': 'senoufu',
      'title': 'Senoufu',
      'img': 'assets/musics/senoufu/senoufo.jpg',
    },
  ];

  final List<Map<String, String>> artistes = [
    {
      'id': 'aly',
      'name': 'Aly Farka Touré',
      'img': 'assets/images/artistes/alyfarka.jpg',
    },
    {
      'id': 'djeneba',
      'name': 'Djénéba Seck',
      'img': 'assets/images/artistes/djeneba.jpg',
    },
    {
      'id': 'salif',
      'name': 'Salif Keita',
      'img': 'assets/images/artistes/salifkeita.jpg',
    },
    {
      'id': 'oumou',
      'name': 'Oumou Sangaré',
      'img': 'assets/images/artistes/oumou.jpg',
    },
    {
      'id': 'habib',
      'name': 'Habib Koité',
      'img': 'assets/images/artistes/habib.jpg',
    },
  ];

  String query = "";

  @override
  Widget build(BuildContext context) {
    // Filtrer les genres
    final filteredGenres = genres
        .where((g) => g['title']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Filtrer les artistes
    final filteredArtists = artistes
        .where((a) => a['name']!.toLowerCase().contains(query.toLowerCase()))
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
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: bogolan,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => query = value);
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'genre musical, artiste...',
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Musique du Mali",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Découvrez les rythmes qui font vibrer le Mali..."),
            const SizedBox(height: 18),

            // Genres filtrés
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

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: filteredGenres.map((g) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaylistScreen(
                          categoryType: 'genre',
                          id: g['id']!,
                          title: g['title']!,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          g['img']!,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        g['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text(
              "Artistes populaires",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredArtists.length,
                itemBuilder: (_, i) {
                  final a = filteredArtists[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaylistScreen(
                            categoryType: 'artiste',
                            id: a['id']!,
                            title: a['name']!,
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
                            backgroundImage: AssetImage(a['img']!),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a['name']!,
                            textAlign: TextAlign.center,
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

      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: bogolan,
      //   unselectedItemColor: Colors.black54,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.library_music),
      //       label: 'Catalogue',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.trending_up),
      //       label: 'Tendance',
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      //   ],
      // ),
    );
  }
}
