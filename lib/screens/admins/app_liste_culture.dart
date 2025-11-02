import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

class CulturesListePage extends StatefulWidget {
  const CulturesListePage({super.key});

  @override
  State<CulturesListePage> createState() => _CulturesListePageState();
}

class _CulturesListePageState extends State<CulturesListePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String query = '';

  // Contenus culturels
  List<Map<String, dynamic>> musiques = [
    {'titre': 'Djigui', 'auteur': 'Amadou & Mariam', 'approuve': false},
    {'titre': 'Yéké Yéké', 'auteur': 'Mory Kanté', 'approuve': true},
    {'titre': 'Fanta', 'auteur': 'Oumou Sangaré', 'approuve': false},
    {'titre': 'Kôrô Yamy', 'auteur': 'Ali Farka Touré', 'approuve': false},
  ];

  List<Map<String, dynamic>> images = [
    {'titre': 'Masque traditionnel', 'image': 'assets/img1.jpg', 'approuve': false},
    {'titre': 'Peinture murale', 'image': 'assets/img2.jpg', 'approuve': true},
    {'titre': 'Sculpture Dogon', 'image': 'assets/img3.jpg', 'approuve': false},
    {'titre': 'Art textile', 'image': 'assets/img4.jpg', 'approuve': true},
  ];

  List<Map<String, dynamic>> proverbes = [
    {'texte': 'Le lion ne se vante pas de sa force.', 'origine': 'Proverbe malien', 'approuve': false},
    {'texte': 'Patience est mère de réussite.', 'origine': 'Proverbe africain', 'approuve': true},
    {'texte': 'Qui veut voyager loin ménage sa monture.', 'origine': 'Proverbe africain', 'approuve': false},
    {'texte': 'L’arbre ne tombe pas au premier coup.', 'origine': 'Proverbe malien', 'approuve': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget _buildCard(Map<String, dynamic> item, String type) {
    String title = '';
    String subtitle = '';
    Widget? leading;

    switch (type) {
      case 'Musique':
        title = item['titre'];
        subtitle = item['auteur'];
        // 💡 Remplacer les images par une icône de musique
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

    // 💡 Carte cliquable
    return InkWell(
      onTap: () {
        // Exemple de navigation (à remplacer plus tard par la page de détails)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ouvrir détails : $title')));
      },
      child: Card(
        color: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: leading,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(color: Colors.white70)) : null,
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'Voir') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voir : $title')));
              } else if (value == 'Approuver') {
                setState(() => item['approuve'] = true);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title approuvé')));
              } else if (value == 'Modifier') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Modifier : $title')));
              } else if (value == 'Supprimer') {
                setState(() {
                  switch (type) {
                    case 'Musique':
                      musiques.remove(item);
                      break;
                    case 'Image':
                      images.remove(item);
                      break;
                    case 'Proverbe':
                      proverbes.remove(item);
                      break;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title supprimé')));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Voir',
                child: Row(children: [Icon(Icons.visibility, color: AppColors.primary), SizedBox(width: 10), Text('Voir')]),
              ),
              if (!item['approuve'])
                const PopupMenuItem(
                  value: 'Approuver',
                  child: Row(children: [Icon(Icons.check, color: Colors.green), SizedBox(width: 10), Text('Approuver')]),
                ),
              const PopupMenuItem(
                value: 'Modifier',
                child: Row(children: [Icon(Icons.edit, color: AppColors.primary), SizedBox(width: 10), Text('Modifier')]),
              ),
              const PopupMenuItem(
                value: 'Supprimer',
                child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 10), Text('Supprimer')]),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  itemBuilder: (context, index) => _buildCard(_filterList(musiques)[index], 'Musique'),
                ),
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filterList(images).length,
                  itemBuilder: (context, index) => _buildCard(_filterList(images)[index], 'Image'),
                ),
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filterList(proverbes).length,
                  itemBuilder: (context, index) => _buildCard(_filterList(proverbes)[index], 'Proverbe'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
