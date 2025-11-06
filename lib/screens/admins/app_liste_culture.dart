import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/screens/musiques/music_player_screen.dart';

class CulturesListePage extends StatefulWidget {
  const CulturesListePage({super.key});

  @override
  State<CulturesListePage> createState() => _CulturesListePageState();
}

class _CulturesListePageState extends State<CulturesListePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String query = '';

  List<Map<String, dynamic>> musiques = [
    {
      'titre': 'Djigui',
      'auteur': 'Amadou & Mariam',
      'genre': 'Traditionnelle',
      'image': 'assets/img1.jpg',
      'fichier': 'assets/musics/bambara/Oumou_Sangaré_-_Diaraby_Nene.mp3',
      'approuve': false,
    },
    {
      'titre': 'Yéké Yéké',
      'auteur': 'Mory Kanté',
      'genre': 'Moderne',
      'image': 'assets/img2.jpg',
      'fichier': 'assets/musics/bambara/Oumou_Sangare_-_Wayeina.mp3',
      'approuve': false,
    },
  ];

  List<Map<String, dynamic>> images = [
    {
      'titre': 'Masque traditionnel',
      'image': 'assets/img1.jpg',
      'approuve': false,
    },
    {'titre': 'Peinture murale', 'image': 'assets/img2.jpg', 'approuve': false},
  ];

  List<Map<String, dynamic>> proverbes = [
    {
      'texte': 'Le lion ne se vante pas de sa force.',
      'origine': 'Proverbe malien',
      'approuve': false,
    },
    {
      'texte': 'Patience est mère de réussite.',
      'origine': 'Proverbe africain',
      'approuve': false,
    },
  ];

  List<Map<String, dynamic>> contes = [
    {
      'titre': 'Le lièvre et la tortue',
      'texte':
          'Un jour, la tortue défia le lièvre à la course. Le lièvre se moqua, sûr de sa victoire. Mais confiant, il s’endormit sur le chemin, tandis que la tortue avança lentement mais sûrement... et arriva la première.',
      'origine': 'Conte africain',
      'approuve': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 🔹 Afficher une image (Asset ou Fichier local)
  void _viewImage(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.textPrimary,
            title: Text(
              item['titre'],
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          body: Center(
            child: item['image'].toString().startsWith('assets/')
                ? Image.asset(item['image'], fit: BoxFit.contain)
                : Image.file(File(item['image']), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  // 🔹 Afficher un conte complet
  void _viewConte(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text(
              item['titre'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((item['origine'] ?? '').isNotEmpty)
                    Text(
                      item['origine'] ?? '',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    item['texte'] ?? '',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Modifier un proverbe
  void _editProverbe(Map<String, dynamic> item) {
    final TextEditingController _editController = TextEditingController(
      text: item['texte'],
    );
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() => item['texte'] = _editController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Proverbe modifié')));
            },
            child: const Text(
              'Enregistrer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Modifier un conte
  void _editConte(Map<String, dynamic> item) {
    final TextEditingController _titreCtrl = TextEditingController(
      text: item['titre'],
    );
    final TextEditingController _origCtrl = TextEditingController(
      text: item['origine'],
    );
    final TextEditingController _texteCtrl = TextEditingController(
      text: item['texte'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Modifier le conte",
          style: TextStyle(color: AppColors.primary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titreCtrl,
                decoration: const InputDecoration(
                  labelText: "Titre du conte",
                  fillColor: AppColors.primary,
                ),
              ),
              TextField(
                controller: _origCtrl,
                decoration: const InputDecoration(
                  labelText: "Origine",
                  fillColor: AppColors.primary,
                ),
              ),
              TextField(
                controller: _texteCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: "Texte complet du conte",
                  fillColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() {
                item['titre'] = _titreCtrl.text;
                item['origine'] = _origCtrl.text;
                item['texte'] = _texteCtrl.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conte modifié avec succès')),
              );
            },
            child: const Text(
              "Enregistrer",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Jouer une musique
  void _playMusic(Map<String, dynamic> item) {
    final path = item['fichier'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MusicPlayerScreen(
          tracks: [
            {
              'path': path,
              'title': item['titre'],
              'artist': item['auteur'] ?? 'Artiste inconnu',
              'img': item['image'],
              'isLocal': !path.toString().startsWith('assets/'),
            },
          ],
          index: 0,
        ),
      ),
    );
  }

  // 🔹 Construire une carte
  Widget _buildCard(Map<String, dynamic> item, String type) {
    String title = '';
    String subtitle = '';
    Widget leading = const CircleAvatar(
      radius: 25,
      child: Icon(Icons.image, color: AppColors.primary),
    );

    switch (type) {
      case 'Musique':
        title = item['titre'] ?? 'Sans titre';
        final auteur = (item['auteur'] ?? '').toString();
        final genre = (item['genre'] ?? '').toString();
        subtitle =
            (auteur.isNotEmpty ? auteur : 'Inconnu') +
            (genre.isNotEmpty ? ' • $genre' : '');
        if (item['image'] != null) {
          final img = item['image'].toString();
          leading = CircleAvatar(
            radius: 25,
            backgroundImage: img.startsWith('assets/')
                ? AssetImage(img) as ImageProvider
                : FileImage(File(img)) as ImageProvider,
          );
        } else {
          leading = const CircleAvatar(
            radius: 25,
            child: Icon(Icons.music_note, color: AppColors.primary),
          );
        }
        break;
      case 'Image':
        title = item['titre'] ?? 'Sans titre';
        if (item['image'] != null) {
          final img = item['image'].toString();
          leading = CircleAvatar(
            radius: 25,
            backgroundImage: img.startsWith('assets/')
                ? AssetImage(img) as ImageProvider
                : FileImage(File(img)) as ImageProvider,
          );
        } else {
          leading = const CircleAvatar(
            radius: 25,
            child: Icon(Icons.image, color: AppColors.primary),
          );
        }
        break;
      case 'Proverbe':
        title = item['texte'] ?? '';
        subtitle = item['origine'] ?? '';
        leading = const CircleAvatar(
          radius: 25,
          child: Icon(Icons.book, color: Colors.white),
          backgroundColor: Color(0xFF007A5A),
        );
        break;
      case 'Conte': // NOUVEAU
        title = item['titre'];

        String? contenu = item['contenu'] as String?;
        // Affichage d'un extrait de 50 caractères
        subtitle = contenu?.substring(0, contenu.length.clamp(0, 50)) ?? '';

        if (subtitle.length < (contenu?.length ?? 0)) {
          subtitle += '...';
        }

        leading = const CircleAvatar(
          radius: 25,
          child: Icon(Icons.menu_book, color: Colors.white),
          backgroundColor: Color(0xFF007A5A),
        );
        break;
      case 'Conte':
        title = item['titre'] ?? 'Sans titre';
        subtitle = item['origine'] ?? '';
        leading = const CircleAvatar(
          radius: 25,
          child: Icon(Icons.menu_book, color: AppColors.primary),
        );
        break;
    }

    return Card(
      color: item['approuve'] == true
          ? AppColors.primary.withOpacity(0.7)
          : AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (type == 'Musique') _playMusic(item);
          if (type == 'Image') _viewImage(item);
          if (type == 'Conte') _viewConte(item);
        },
        child: ListTile(
          leading: leading,
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: subtitle.isNotEmpty
              ? Text(subtitle, style: const TextStyle(color: Colors.white70))
              : null,
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'Approuver')
                setState(() => item['approuve'] = true);
              else if (value == 'Modifier' && type == 'Proverbe')
                _editProverbe(item);
              else if (value == 'Lire' && type == 'Musique')
                _playMusic(item);
              else if (value == 'Voir' && type == 'Image')
                _viewImage(item);
              else if (value == 'LireConte' && type == 'Conte')
                _viewConte(item);
              else if (value == 'Modifier' && type == 'Conte')
                _editConte(item);
              else if (value == 'Supprimer') {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Confirmation'),
                    content: const Text(
                      'Voulez-vous vraiment supprimer cet élément ?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (type == 'Musique') musiques.remove(item);
                            if (type == 'Image') images.remove(item);
                            if (type == 'Proverbe') proverbes.remove(item);
                            if (type == 'Conte') contes.remove(item);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];
              if (item['approuve'] != true) {
                items.add(
                  const PopupMenuItem(
                    value: 'Approuver',
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 10),
                        Text('Approuver'),
                      ],
                    ),
                  ),
                );
              }

              if (type == 'Musique') {
                items.add(
                  const PopupMenuItem(
                    value: 'Lire',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text('Lire'),
                      ],
                    ),
                  ),
                );
              }
              if (type == 'Image') {
                items.add(
                  const PopupMenuItem(
                    value: 'Voir',
                    child: Row(
                      children: [
                        Icon(Icons.remove_red_eye, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text('Voir'),
                      ],
                    ),
                  ),
                );
              }
              if (type == 'Conte') {
                items.add(
                  const PopupMenuItem(
                    value: 'LireConte',
                    child: Row(
                      children: [
                        Icon(Icons.menu_book, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text('Lire'),
                      ],
                    ),
                  ),
                );
                items.add(
                  const PopupMenuItem(
                    value: 'Modifier',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                );
              }
              if (type == 'Proverbe') {
                items.add(
                  const PopupMenuItem(
                    value: 'Modifier',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                );
              }
              items.add(
                const PopupMenuItem(
                  value: 'Supprimer',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Supprimer'),
                    ],
                  ),
                ),
              );
              return items;
            },
          ),
        ),
      ),
    );
  }

  // 🔹 Filtrage
  List<Map<String, dynamic>> _filterList(List<Map<String, dynamic>> list) {
    final s = query.toLowerCase();
    if (s.isEmpty) return list;
    return list.where((item) {
      return (item['titre']?.toString().toLowerCase() ?? '').contains(s) ||
          (item['auteur']?.toString().toLowerCase() ?? '').contains(s) ||
          (item['genre']?.toString().toLowerCase() ?? '').contains(s) ||
          (item['texte']?.toString().toLowerCase() ?? '').contains(s) ||
          (item['origine']?.toString().toLowerCase() ?? '').contains(s);
    }).toList();
  }

  // 🔹 Boîte d’ajout musique (avec image via ImagePicker)
  void _addMusic() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.single.path == null) return;

    final fichierPath = result.files.single.path!;
    final titre = result.files.single.name;

    final TextEditingController _auteurCtrl = TextEditingController();
    final TextEditingController _genreCtrl = TextEditingController();
    XFile? pickedImage;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Nouvelle musique"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("Fichier : $titre"),
                TextField(
                  controller: _auteurCtrl,
                  decoration: const InputDecoration(labelText: "Auteur"),
                ),
                TextField(
                  controller: _genreCtrl,
                  decoration: const InputDecoration(labelText: "Genre"),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final img = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (img != null) {
                      setStateDialog(() => pickedImage = img);
                    }
                  },
                  child: pickedImage == null
                      ? Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(child: Text("Choisir une image")),
                        )
                      : Image.file(
                          File(pickedImage!.path),
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                setState(() {
                  musiques.add({
                    'titre': titre,
                    'auteur': _auteurCtrl.text.isEmpty
                        ? 'Inconnu'
                        : _auteurCtrl.text,
                    'genre': _genreCtrl.text.isEmpty
                        ? 'Inconnu'
                        : _genreCtrl.text,
                    'image': pickedImage?.path ?? 'assets/img1.jpg',
                    'fichier': fichierPath,
                    'approuve': false,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Ajouter",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Ajouter une image (choix fichier image + titre)
  void _addImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final name = result.files.single.name;
    final TextEditingController _titleCtrl = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Titre de l'image"),
        content: TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(
            labelText: "Entrez le titre de l'image",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() {
                images.add({
                  'titre': _titleCtrl.text.isEmpty ? name : _titleCtrl.text,
                  'image': path,
                  'approuve': false,
                });
              });
              Navigator.pop(context);
            },
            child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔹 Ajouter un proverbe
  void _addProverbe() {
    final TextEditingController _textCtrl = TextEditingController();
    final TextEditingController _origCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un proverbe"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textCtrl,
              decoration: const InputDecoration(labelText: "Texte du proverbe"),
            ),
            TextField(
              controller: _origCtrl,
              decoration: const InputDecoration(labelText: "Origine"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() {
                proverbes.add({
                  'texte': _textCtrl.text,
                  'origine': _origCtrl.text,
                  'approuve': false,
                });
              });
              Navigator.pop(context);
            },
            child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔹 Ajouter un conte
  void _addConte() {
    final TextEditingController _titreCtrl = TextEditingController();
    final TextEditingController _texteCtrl = TextEditingController();
    final TextEditingController _origCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un conte"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titreCtrl,
                decoration: const InputDecoration(labelText: "Titre du conte"),
              ),
              TextField(
                controller: _origCtrl,
                decoration: const InputDecoration(labelText: "Origine"),
              ),
              TextField(
                controller: _texteCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: "Texte complet du conte",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() {
                contes.add({
                  'titre': _titreCtrl.text,
                  'texte': _texteCtrl.text,
                  'origine': _origCtrl.text,
                  'approuve': false,
                });
              });
              Navigator.pop(context);
            },
            child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔹 Boîte d’ajout principal (route vers le bon add)
  void _showAddDialog() {
    switch (_tabController.index) {
      case 0:
        _addMusic();
        break;
      case 1:
        _addImage();
        break;
      case 2:
        _addProverbe();
        break;
      case 3:
        _addConte();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Gestion Contenu Culturel',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
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
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
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
              Tab(text: "Contes"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  children: _filterList(
                    musiques,
                  ).map((e) => _buildCard(e, 'Musique')).toList(),
                ),
                ListView(
                  children: _filterList(
                    images,
                  ).map((e) => _buildCard(e, 'Image')).toList(),
                ),
                ListView(
                  children: _filterList(
                    proverbes,
                  ).map((e) => _buildCard(e, 'Proverbe')).toList(),
                ),
                ListView(
                  children: _filterList(
                    contes,
                  ).map((e) => _buildCard(e, 'Conte')).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
