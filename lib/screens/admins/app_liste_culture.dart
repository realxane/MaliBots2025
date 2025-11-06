import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
// NOUVEAUX IMPORTS pour la gestion des fichiers
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// --- WIDGETS DE FORMULAIRES D'AJOUT ---

// Fonction utilitaire pour afficher les modales des formulaires
void _showContentForm(
  BuildContext context,
  String type,
  Function(Map<String, dynamic>) onSave,
) {
  Widget form;
  switch (type) {
    case 'Musique':
      form = AddMusicForm(onSave: onSave);
      break;
    case 'Image':
      form = AddImageForm(onSave: onSave);
      break;
    case 'Proverbe':
      form = AddProverbeForm(onSave: onSave);
      break;
    case 'Conte':
      form = AddConteForm(onSave: onSave);
      break;
    default:
      return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      // Important pour éviter que le clavier ne cache les champs
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: form,
    ),
  );
}

// Formulaire d'ajout de Musique
class AddMusicForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const AddMusicForm({super.key, required this.onSave});

  @override
  State<AddMusicForm> createState() => _AddMusicFormState();
}

class _AddMusicFormState extends State<AddMusicForm> {
  final _formKey = GlobalKey<FormState>();
  String _titre = '';
  String _artiste = '';
  String _genre = '';

  // NOUVELLES VARIABLES pour les fichiers
  File? _selectedImageFile; // Pour la pochette
  File? _selectedMp3File; // Pour le fichier audio
  final ImagePicker _picker = ImagePicker();

  // NOUVELLE LOGIQUE: Sélectionner image (pochette)
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  // NOUVELLE LOGIQUE: Sélectionner fichier MP3/Audio
  Future<void> _pickMp3File() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // Filtre les extensions audio courantes
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedMp3File = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🎵 Ajouter une Nouvelle Musique',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (v) => v!.isEmpty ? 'Entrez le titre' : null,
              onSaved: (v) => _titre = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nom de l\'Artiste'),
              validator: (v) => v!.isEmpty ? 'Entrez l\'artiste' : null,
              onSaved: (v) => _artiste = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Genre (Bambara, Sonraï, etc.)',
              ),
              validator: (v) => v!.isEmpty ? 'Entrez le genre' : null,
              onSaved: (v) => _genre = v!,
            ),
            // --- Logique d'importation Image (Pochette) ---
            ListTile(
              title: Text(
                _selectedImageFile == null
                    ? 'Sélectionner Image (Pochette)'
                    : 'Image: ${_selectedImageFile!.path.split('/').last}',
              ),
              trailing: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              onTap: _pickImageFromGallery,
            ),
            // --- Logique d'importation Audio ---
            ListTile(
              title: Text(
                _selectedMp3File == null
                    ? 'Importer Fichier Audio (MP3/M4A)'
                    : 'Audio: ${_selectedMp3File!.path.split('/').last}',
              ),
              trailing: const Icon(Icons.audiotrack, color: AppColors.primary),
              onTap: _pickMp3File,
            ),
            // -------------------------------------------------------------------------
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _selectedImageFile != null && // Validation du fichier image
                    _selectedMp3File != null) {
                  // Validation du fichier audio
                  _formKey.currentState!.save();
                  widget.onSave({
                    'titre': _titre,
                    'auteur': _artiste,
                    'genre': _genre,
                    'image': _selectedImageFile!
                        .path, // Chemin réel du fichier image
                    'fichierMp3':
                        _selectedMp3File!.path, // Chemin réel du fichier audio
                    'approuve': false,
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Veuillez sélectionner l\'image et le fichier audio.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Ajouter Musique'),
            ),
          ],
        ),
      ),
    );
  }
}

// Formulaire d'ajout d'Image/Œuvre
class AddImageForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const AddImageForm({super.key, required this.onSave});

  @override
  State<AddImageForm> createState() => _AddImageFormState();
}

class _AddImageFormState extends State<AddImageForm> {
  final _formKey = GlobalKey<FormState>();
  String _titre = '';
  String _description = '';
  String _ethenie = '';
  String _region = '';

  // NOUVELLE VARIABLE: Liste de fichiers pour la sélection multiple
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // NOUVELLE LOGIQUE: Sélectionner une ou plusieurs images depuis la galerie
  Future<void> _pickImageFromGallery() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage(
      imageQuality: 70, // Optimisation
    );

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🖼️ Ajouter une Nouvelle Image/Œuvre',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            // --- Logique d'importation Image MISE À JOUR ---
            ListTile(
              title: Text(
                _selectedImages.isEmpty
                    ? 'Sélectionner 1 ou plusieurs images (Galerie)'
                    : '${_selectedImages.length} image(s) sélectionnée(s)',
              ),
              trailing: const Icon(Icons.collections, color: AppColors.primary),
              onTap: _pickImageFromGallery, // Appel de la fonction réelle
            ),
            // Affiche les noms de fichiers pour l'utilisateur
            if (_selectedImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Fichier(s) : ${_selectedImages.map((f) => f.path.split('/').last).join(', ')}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            // -------------------------------------------------------------------------
            TextFormField(
              decoration: const InputDecoration(labelText: 'Titre de l\'Œuvre'),
              validator: (v) => v!.isEmpty ? 'Entrez un titre' : null,
              onSaved: (v) => _titre = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
              validator: (v) => v!.isEmpty ? 'Entrez une description' : null,
              onSaved: (v) => _description = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Ethnie'),
              onSaved: (v) => _ethenie = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Région'),
              onSaved: (v) => _region = v!,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _selectedImages.isNotEmpty) {
                  // Validation des images
                  _formKey.currentState!.save();
                  widget.onSave({
                    'titre': _titre,
                    'description': _description,
                    'ethenie': _ethenie,
                    'region': _region,
                    // Envoie le chemin de la première image (ajuster si vous gérez plusieurs)
                    'image': _selectedImages.first.path,
                    'approuve': false,
                  });
                  Navigator.pop(context);
                } else if (_selectedImages.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Veuillez sélectionner au moins une image.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Ajouter Image/Œuvre'),
            ),
          ],
        ),
      ),
    );
  }
}

// Formulaire d'ajout de Proverbe (inchangé)
class AddProverbeForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const AddProverbeForm({super.key, required this.onSave});

  @override
  State<AddProverbeForm> createState() => _AddProverbeFormState();
}

class _AddProverbeFormState extends State<AddProverbeForm> {
  final _formKey = GlobalKey<FormState>();
  String _texte = '';
  String _signification = '';
  String _langue = '';
  String _origine = 'Proverbe malien';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '📘 Ajouter un Nouveau Proverbe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Texte du Proverbe'),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Entrez le proverbe' : null,
              onSaved: (v) => _texte = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Signification (Optionnel)',
              ),
              maxLines: 2,
              onSaved: (v) => _signification = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Langue (Bambara, Français, etc.)',
              ),
              onSaved: (v) => _langue = v!,
            ),
            TextFormField(
              initialValue: 'Proverbe malien',
              decoration: const InputDecoration(labelText: 'Origine'),
              onSaved: (v) => _origine = v!,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onSave({
                    'texte': _texte,
                    'signification': _signification,
                    'langue': _langue,
                    'origine': _origine,
                    'approuve': false,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Ajouter Proverbe'),
            ),
          ],
        ),
      ),
    );
  }
}

// Formulaire d'ajout de Conte (inchangé)
class AddConteForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const AddConteForm({super.key, required this.onSave});

  @override
  State<AddConteForm> createState() => _AddConteFormState();
}

class _AddConteFormState extends State<AddConteForm> {
  final _formKey = GlobalKey<FormState>();
  String _titre = '';
  String _contenu = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '📜 Ajouter un Nouveau Conte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Titre du Conte'),
              validator: (v) => v!.isEmpty ? 'Entrez le titre du conte' : null,
              onSaved: (v) => _titre = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Contenu du Conte'),
              maxLines: 5,
              validator: (v) =>
                  v!.isEmpty ? 'Entrez le contenu du conte' : null,
              onSaved: (v) => _contenu = v!,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onSave({
                    'titre': _titre,
                    'contenu': _contenu,
                    'approuve': false,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Ajouter Conte'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CLASSE PRINCIPALE (CulturesListePage) MISE À JOUR ---

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

  // Contenus culturels (Données initiales)
  List<Map<String, dynamic>> musiques = [
    {
      'titre': 'Djigui',
      'auteur': 'Amadou & Mariam',
      'approuve': false,
      'image': 'assets/img1.jpg',
    }, // Simulation d'image
    {
      'titre': 'Yéké Yéké',
      'auteur': 'Mory Kanté',
      'approuve': true,
      'image': 'assets/img2.jpg',
    },
    {
      'titre': 'Fanta',
      'auteur': 'Oumou Sangaré',
      'approuve': false,
      'image': 'assets/img3.jpg',
    },
    {
      'titre': 'Kôrô Yamy',
      'auteur': 'Ali Farka Touré',
      'approuve': false,
      'image': 'assets/img4.jpg',
    },
  ];

  List<Map<String, dynamic>> images = [
    {
      'titre': 'Masque traditionnel',
      'image': 'assets/img1.jpg',
      'approuve': false,
    },
    {'titre': 'Peinture murale', 'image': 'assets/img2.jpg', 'approuve': true},
    {'titre': 'Sculpture Dogon', 'image': 'assets/img3.jpg', 'approuve': false},
    {'titre': 'Art textile', 'image': 'assets/img4.jpg', 'approuve': true},
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
      'approuve': true,
    },
    {
      'texte': 'Qui veut voyager loin ménage sa monture.',
      'origine': 'Proverbe africain',
      'approuve': false,
    },
  ];

  // Contenu Contes
  List<Map<String, dynamic>> contes = [
    {
      'titre': 'Le lièvre et l\'hyène',
      'contenu': 'Un conte populaire sur la ruse du lièvre.',
      'approuve': false,
    },
    {
      'titre': 'La légende de Soundiata Keïta',
      'contenu':
          'L\'histoire fondatrice de l\'empire du Mali est un long récit épique.',
      'approuve': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Le nombre d'onglets est maintenant 4
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fonction pour ajouter un nouvel élément
  void _addItem(String type, Map<String, dynamic> item) {
    setState(() {
      switch (type) {
        case 'Musique':
          musiques.insert(0, item);
          break;
        case 'Image':
          images.insert(0, item);
          break;
        case 'Proverbe':
          proverbes.insert(0, item);
          break;
        case 'Conte':
          contes.insert(0, item);
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type "${item['titre'] ?? item['texte']}" ajouté!'),
        ),
      );
    });
  }

  Widget _buildCard(Map<String, dynamic> item, String type) {
    String title = '';
    String subtitle = '';
    Widget? leading;

    switch (type) {
      case 'Musique':
        title = item['titre'];
        subtitle = item['auteur'] ?? '';

        // Gère l'affichage des images (Asset ou File)
        final imagePath = item['image'] as String?;
        if (imagePath != null) {
          if (imagePath.startsWith('assets/')) {
            leading = CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(imagePath),
            );
          } else {
            // Suppose que c'est un chemin de fichier local après importation
            leading = CircleAvatar(
              radius: 25,
              backgroundImage: FileImage(File(imagePath)),
              onBackgroundImageError: (exception, stackTrace) =>
                  const Icon(Icons.music_note, color: Colors.white),
            );
          }
        } else {
          leading = const CircleAvatar(
            radius: 25,
            child: Icon(Icons.music_note, color: Colors.white),
            backgroundColor: Color(0xFF007A5A),
          );
        }
        break;
      case 'Image':
        title = item['titre'];

        final imagePath = item['image'] as String?;
        if (imagePath != null) {
          if (imagePath.startsWith('assets/')) {
            leading = CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(imagePath),
            );
          } else {
            // Suppose que c'est un chemin de fichier local après importation
            leading = CircleAvatar(
              radius: 25,
              backgroundImage: FileImage(File(imagePath)),
              onBackgroundImageError: (exception, stackTrace) =>
                  const Icon(Icons.image, color: Colors.white),
            );
          }
        } else {
          leading = const CircleAvatar(
            radius: 25,
            child: Icon(Icons.image, color: Colors.white),
            backgroundColor: Color(0xFF007A5A),
          );
        }
        break;
      case 'Proverbe':
        title = item['texte'];
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
    }

    // 💡 Carte cliquable
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ouvrir détails : $title')));
      },
      child: Card(
        color: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 6),
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
              if (value == 'Approuver') {
                setState(() => item['approuve'] = true);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$title approuvé')));
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
                    case 'Conte':
                      contes.remove(item);
                      break;
                  }
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$title supprimé')));
              }
              // Les autres actions (Voir, Modifier) peuvent être implémentées plus tard
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Voir',
                child: Row(
                  children: [
                    Icon(Icons.visibility, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text('Voir'),
                  ],
                ),
              ),
              if (!item['approuve'])
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
            ],
          ),
        ),
      ),
    );
  }

  // Fonction de filtrage
  List<Map<String, dynamic>> _filterList(List<Map<String, dynamic>> list) {
    if (query.isEmpty) return list;
    final searchLower = query.toLowerCase();

    return list.where((item) {
      // Recherche dans tous les champs pertinents
      return (item['titre']?.toLowerCase() ?? '').contains(searchLower) ||
          (item['auteur']?.toLowerCase() ?? '').contains(searchLower) ||
          (item['texte']?.toLowerCase() ?? '').contains(searchLower) ||
          (item['origine']?.toLowerCase() ?? '').contains(searchLower) ||
          (item['contenu']?.toLowerCase() ?? '').contains(
            searchLower,
          ); // Pour Contes
    }).toList();
  }

  // Widget qui combine le ListView et le FloatingActionButton (pour chaque onglet)
  Widget _buildTabContent(List<Map<String, dynamic>> list, String type) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filterList(list).length,
          itemBuilder: (context, index) =>
              _buildCard(_filterList(list)[index], type),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            // Le heroTag est nécessaire pour différencier les FAB
            heroTag: 'fab$type',
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: () => _showContentForm(context, type, (newItem) {
              _addItem(type, newItem);
            }),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
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
              Tab(text: "Contes"), // NOUVEAU
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(musiques, 'Musique'),
                _buildTabContent(images, 'Image'),
                _buildTabContent(proverbes, 'Proverbe'),
                _buildTabContent(contes, 'Conte'), // NOUVEAU
              ],
            ),
          ),
        ],
      ),
    );
  }
}
