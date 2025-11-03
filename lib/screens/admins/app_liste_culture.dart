import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/screens/musiques/music_player_screen.dart';

class CulturesListePage extends StatefulWidget {
  const CulturesListePage({super.key});

  @override
  State<CulturesListePage> createState() => _CulturesListePageState();
}

class _CulturesListePageState extends State<CulturesListePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String query = '';

  List<Map<String, dynamic>> musiques = [
    {
      'titre': 'Djigui',
      'auteur': 'Amadou & Mariam',
      'fichier': 'assets/musics/bambara/Oumou_Sangaré_-_Diaraby_Nene.mp3',
      'approuve': false
    },
    {
      'titre': 'Yéké Yéké',
      'auteur': 'Mory Kanté',
      'fichier': 'assets/musics/bambara/Oumou_Sangare_-_Wayeina.mp3',
      'approuve': false
    },
  ];

  List<Map<String, dynamic>> images = [
    {'titre': 'Masque traditionnel', 'image': 'assets/img1.jpg', 'approuve': false},
    {'titre': 'Peinture murale', 'image': 'assets/img2.jpg', 'approuve': false},
  ];

  List<Map<String, dynamic>> proverbes = [
    {'texte': 'Le lion ne se vante pas de sa force.', 'origine': 'Proverbe malien', 'approuve': false},
    {'texte': 'Patience est mère de réussite.', 'origine': 'Proverbe africain', 'approuve': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 🔹 Fonction pour afficher une image
  void _viewImage(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 Text(item['titre'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: AppColors.primary)),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    item['image'],
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Modifier un proverbe
  void _editProverbe(Map<String, dynamic> item) {
    final TextEditingController _editController = TextEditingController(text: item['texte']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le proverbe'),
        content: TextField(
          controller: _editController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Texte du proverbe',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() => item['texte'] = _editController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proverbe modifié')));
            },
            child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔹 Ouvrir le lecteur de musique
  void _playMusic(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MusicPlayerScreen(
          tracks: [
            {
              'path': item['fichier'],
              'title': item['titre'],
              'artist': item['auteur'] ?? 'Artiste inconnu',
              'img': 'assets/img_music_placeholder.jpg',
            }
          ],
          index: 0,
        ),
      ),
    );
  }

  // 🔹 Construire une carte cliquable
  Widget _buildCard(Map<String, dynamic> item, String type) {
    String title = '';
    String subtitle = '';
    Widget? leading;

    switch (type) {
      case 'Musique':
        title = item['titre'];
        subtitle = item['auteur'];
        leading = const CircleAvatar(
          radius: 25,
          child: Icon(Icons.music_note, color: AppColors.primary),
        );
        break;
      case 'Image':
        title = item['titre'];
        leading = item['image'] != null
            ? CircleAvatar(radius: 25, backgroundImage: AssetImage(item['image']))
            : const CircleAvatar(radius: 25, child: Icon(Icons.image, color: AppColors.primary));
        break;
      case 'Proverbe':
        title = item['texte'];
        subtitle = item['origine'] ?? '';
        leading = const CircleAvatar(radius: 25, child: Icon(Icons.book, color: AppColors.primary));
        break;
    }

    return Card(
      color: item['approuve'] ? AppColors.primary.withOpacity(0.7) : AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (type == 'Musique') {
            _playMusic(item);
          } else if (type == 'Image') {
            _viewImage(item);
          }
        },
        child: ListTile(
          leading: leading,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(color: Colors.white70)) : null,
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'Approuver') {
                setState(() => item['approuve'] = true);
              } else if (value == 'Modifier' && type == 'Proverbe') {
                _editProverbe(item);
              } else if (value == 'Lire' && type == 'Musique') {
                _playMusic(item);
              } else if (value == 'Voir' && type == 'Image') {
                _viewImage(item);
              } else if (value == 'Supprimer') {
                setState(() {
                  if (type == 'Musique') musiques.remove(item);
                  if (type == 'Image') images.remove(item);
                  if (type == 'Proverbe') proverbes.remove(item);
                });
              }
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];

              if (!item['approuve']) {
                items.add(const PopupMenuItem(
                  value: 'Approuver',
                  child: Row(
                    children: [Icon(Icons.check, color: Colors.green), SizedBox(width: 10), Text('Approuver')],
                  ),
                ));
              }

              if (type == 'Musique') {
                items.add(const PopupMenuItem(
                  value: 'Lire',
                  child: Row(
                    children: [Icon(Icons.play_arrow, color: AppColors.primary), SizedBox(width: 10), Text('Lire')],
                  ),
                ));
              }

              if (type == 'Image') {
                items.add(const PopupMenuItem(
                  value: 'Voir',
                  child: Row(
                    children: [Icon(Icons.remove_red_eye, color: AppColors.primary), SizedBox(width: 10), Text('Voir')],
                  ),
                ));
              }

              if (type == 'Proverbe') {
                items.add(const PopupMenuItem(
                  value: 'Modifier',
                  child: Row(
                    children: [Icon(Icons.edit, color: AppColors.primary), SizedBox(width: 10), Text('Modifier')],
                  ),
                ));
              }

              items.add(const PopupMenuItem(
                value: 'Supprimer',
                child: Row(
                  children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 10), Text('Supprimer')],
                ),
              ));

              return items;
            },
          ),
        ),
      ),
    );
  }

  // 🔹 Filtrer selon la recherche
  List<Map<String, dynamic>> _filterList(List<Map<String, dynamic>> list) {
    return list.where((item) {
      final searchLower = query.toLowerCase();
      return (item['titre']?.toLowerCase() ?? '').contains(searchLower) ||
          (item['auteur']?.toLowerCase() ?? '').contains(searchLower) ||
          (item['texte']?.toLowerCase() ?? '').contains(searchLower) ||
          (item['origine']?.toLowerCase() ?? '').contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Gestion Contenu Culturel', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un contenu...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Musiques"),
              Tab(text: "Images"),
              Tab(text: "Proverbes"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filterList(musiques).length,
                  itemBuilder: (context, i) => _buildCard(_filterList(musiques)[i], 'Musique'),
                ),
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filterList(images).length,
                  itemBuilder: (context, i) => _buildCard(_filterList(images)[i], 'Image'),
                ),
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filterList(proverbes).length,
                  itemBuilder: (context, i) => _buildCard(_filterList(proverbes)[i], 'Proverbe'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
