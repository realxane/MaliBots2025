import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/screens/musiques/music_player_screen.dart';
import 'package:malibots_challenge_eni/services/api_musique_service.dart';
import 'package:malibots_challenge_eni/services/api_photo_service.dart';

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
      'description': 'Masque Bambara utilisé lors des cérémonies.',
      'ethnie': 'Bambara',
      'images': ['assets/img1.jpg'],
      'approuve': false,
    },
    {
      'titre': 'Peinture murale',
      'description': 'Peinture murale de la ville de Ouagadougou.',
      'ethnie': 'Bambara',
      'images': ['assets/img2.jpg'],
      'approuve': false,
    },
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
    final List<dynamic>? imageList = item['images'];
    final titre = item['titre'] ?? '';
    final desc = item['description'] ?? '';
    final ethnie = item['ethnie'] ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.textSecondary,
            title: Text(
              titre.isNotEmpty ? titre : 'Détails de l\'image',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: imageList != null && imageList.isNotEmpty
              ? _ImageDetailView(
                  images: imageList.map((e) => e.toString()).toList(),
                  titre: titre,
                  description: desc,
                  ethnie: ethnie,
                )
              : const Center(
                  child: Text(
                    "Aucune image disponible",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
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
            backgroundColor: AppColors.textSecondary,
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
                        color: AppColors.textSecondary,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textSecondary,
            ),
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
          style: TextStyle(color: AppColors.textSecondary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titreCtrl,
                decoration: const InputDecoration(
                  labelText: "Titre du conte",
                  fillColor: AppColors.textSecondary,
                ),
              ),
              TextField(
                controller: _origCtrl,
                decoration: const InputDecoration(
                  labelText: "Origine",
                  fillColor: AppColors.textSecondary,
                ),
              ),
              TextField(
                controller: _texteCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: "Texte complet du conte",
                  fillColor: AppColors.textSecondary,
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
              backgroundColor: AppColors.textSecondary,
            ),
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
  // void _playMusic(Map<String, dynamic> item) {
  //   final path = item['fichier'];
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => MusicPlayerScreen(
  //         tracks: [
  //           {
  //             'path': path,
  //             'title': item['titre'],
  //             'artist': item['auteur'] ?? 'Artiste inconnu',
  //             'img': item['image'],
  //             'isLocal': !path.toString().startsWith('assets/'),
  //           },
  //         ],
  //         index: 0,
  //       ),
  //     ),
  //   );
  // }

  // 🔹 Construire une carte
  Widget _buildCard(Map<String, dynamic> item, String type) {
    String title = '';
    String subtitle = '';
    Widget leading = const CircleAvatar(
      radius: 25,
      child: Icon(Icons.image, color: AppColors.textSecondary),
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
            child: Icon(Icons.music_note, color: AppColors.textSecondary),
          );
        }
        break;
      case 'Image':
        title = item['titre'] ?? 'Sans titre';
        final List<dynamic>? imageList = item['images'];

        // ✅ Utiliser la première image si disponible
        if (imageList != null && imageList.isNotEmpty) {
          final firstImg = imageList.first?.toString();
          if (firstImg != null && firstImg.isNotEmpty) {
            leading = CircleAvatar(
              radius: 25,
              backgroundImage: firstImg.startsWith('assets/')
                  ? AssetImage(firstImg) as ImageProvider
                  : FileImage(File(firstImg)) as ImageProvider,
            );
          } else {
            leading = const CircleAvatar(
              radius: 25,
              child: Icon(Icons.image, color: AppColors.textSecondary),
            );
          }
        } else if (item['image'] != null) {
          // ✅ Pour compatibilité avec anciens éléments ayant 'image' au lieu de 'images'
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
            child: Icon(Icons.image, color: AppColors.textSecondary),
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
          child: Icon(Icons.menu_book, color: AppColors.textSecondary),
        );
        break;
    }

    return Card(
      color: item['approuve'] == true
          ? AppColors.textSecondary.withOpacity(0.7)
          : AppColors.textSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // if (type == 'Musique') _playMusic(item);
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
              //else if (value == 'Lire' && type == 'Musique')
              //  _playMusic(item);
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
                        Icon(Icons.play_arrow, color: AppColors.textSecondary),
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
                        Icon(
                          Icons.remove_red_eye,
                          color: AppColors.textSecondary,
                        ),
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
                        Icon(Icons.menu_book, color: AppColors.textSecondary),
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
                        Icon(Icons.edit, color: AppColors.textSecondary),
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
                        Icon(Icons.edit, color: AppColors.textSecondary),
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

  // Fichier: [Votre fichier d'administration/PlaylistScreen.dart]

  // Assurez-vous que l'instance de l'API est définie dans la classe _[NomDeVotreState]State
  final MusiqueApi api = MusiqueApi();

  void _addMusic() async {
    final TextEditingController titreCtrl = TextEditingController();
    final TextEditingController auteurCtrl = TextEditingController();
    final TextEditingController genreCtrl = TextEditingController();
    XFile? pickedImage; // Image sélectionnée par ImagePicker
    String? fichierPath; // Chemin du fichier audio sélectionné par FilePicker

    // Cette variable gère l'état d'upload dans le dialogue
    bool isUploading = false;

    await showDialog(
      context: context,
      // Utilisation de StatefulBuilder pour mettre à jour l'icône de chargement DANS le dialogue
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Nouvelle musique"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titreCtrl,
                  decoration: const InputDecoration(labelText: "Titre *"),
                ),
                TextField(
                  controller: auteurCtrl,
                  decoration: const InputDecoration(labelText: "Artiste *"),
                ),
                TextField(
                  controller: genreCtrl,
                  decoration: const InputDecoration(labelText: "Genre"),
                ),
                const SizedBox(height: 15),

                // 🎵 Sélecteur de Fichier Audio
                ElevatedButton.icon(
                  onPressed: isUploading
                      ? null
                      : () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.audio,
                          );
                          if (result != null &&
                              result.files.single.path != null) {
                            setStateDialog(
                              () => fichierPath = result.files.single.path!,
                            );
                          }
                        },
                  icon: const Icon(Icons.audiotrack),
                  label: Text(
                    fichierPath == null
                        ? "Choisir le fichier audio *"
                        : "Audio : ${fichierPath!.split('/').last}",
                  ),
                ),
                const SizedBox(height: 15),

                // 🖼️ Sélecteur d'Image
                GestureDetector(
                  onTap: isUploading
                      ? null
                      : () async {
                          final picker = ImagePicker();
                          final img = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (img != null)
                            setStateDialog(() => pickedImage = img);
                        },
                  child: pickedImage == null
                      ? Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text("Choisir une image de couverture"),
                          ),
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
                // Vous devez définir AppColors.textSecondary
                backgroundColor: AppColors.textSecondary,
              ),
              // Désactiver le bouton pendant le chargement
              onPressed: isUploading
                  ? null
                  : () async {
                      // --- VÉRIFICATION DES CHAMPS OBLIGATOIRES ---
                      if (fichierPath == null ||
                          titreCtrl.text.isEmpty ||
                          auteurCtrl.text.isEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Le Titre, l'Artiste et le Fichier audio sont obligatoires.",
                              ),
                            ),
                          );
                        }
                        return;
                      }

                      // --- DÉBUT DE L'UPLOAD ---
                      setStateDialog(() => isUploading = true);

                      try {
                        // Création des objets File nécessaires pour la fonction API
                        final audioFile = File(fichierPath!);
                        final imageFile = pickedImage != null
                            ? File(pickedImage!.path)
                            : null;

                        // Appel de l'API
                        final success = await api.uploadMusique(
                          titre: titreCtrl.text,
                          artist: auteurCtrl.text,
                          genre: genreCtrl.text,
                          image: imageFile,
                          audio: audioFile,
                        );

                        // Gérer la réponse du serveur
                        if (success) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Musique publiée avec succès !"),
                              ),
                            );
                            // Mettre à jour la liste des musiques après succès (si nécessaire)
                            // _loadAndFilterMusiques();
                            Navigator.pop(context); // Fermer le dialogue
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Échec de la publication. Statut non valide du serveur.",
                                ),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // Gérer les erreurs de connexion ou de Dio
                        debugPrint("Erreur UPLOAD: $e");
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Erreur lors de l'envoi: ${e.toString()}",
                              ),
                            ),
                          );
                        }
                      } finally {
                        // Fin du chargement, quel que soit le résultat
                        setStateDialog(() => isUploading = false);
                      }
                    },
              child: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
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

  // Remplacez votre fonction _addImage existante par celle-ci
  void _addImage(BuildContext context) async {
    final TextEditingController _titleCtrl = TextEditingController();
    final TextEditingController _descCtrl = TextEditingController();
    final TextEditingController _regionCtrl =
        TextEditingController(); // Renommé ethnie en region
    List<XFile> pickedImages = [];
    const String adminId = '9aa1d9d0-c00a-11f0-8bc6-80e82c538f4c';

    // L'instance de votre service API
    final PhotoApi photoApi =
        PhotoApi(); // Assurez-vous que cette instance est accessible

    bool isLoading = false; // Pour gérer l'état de chargement

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Nouvelle Publication Photo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: "Titre *"),
                ),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
                TextField(
                  controller: _regionCtrl, // L'admin publie la Region (Ethnie)
                  decoration: const InputDecoration(
                    labelText: "Région (ou Ethnie) *",
                  ),
                ),
                const SizedBox(height: 20),

                // BOUTON CHOIX DES IMAGES
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: Text(
                    pickedImages.isEmpty
                        ? "Choisir les images *"
                        : "${pickedImages.length} image(s) sélectionnée(s)",
                  ),
                  onPressed: () async {
                    final results = await ImagePicker().pickMultiImage();
                    if (results.isNotEmpty) {
                      setStateDialog(() => pickedImages = results);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // AFFICHAGE DE LA PREMIÈRE IMAGE SÉLECTIONNÉE
                if (pickedImages.isNotEmpty)
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(
                      File(pickedImages[0].path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text("Erreur image")),
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

            // BOUTON PUBLIER
            ElevatedButton(
              onPressed: isLoading
                  ? null // Désactiver pendant le chargement
                  : () async {
                      // 1. Validation de base
                      if (_titleCtrl.text.isEmpty ||
                          _regionCtrl.text.isEmpty ||
                          pickedImages.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Veuillez remplir le titre, la région et choisir au moins une image.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setStateDialog(
                        () => isLoading = true,
                      ); // Début du chargement

                      try {
                        // 2. Conversion des XFile en File pour l'API
                        List<File> imageFiles = pickedImages
                            .map((xfile) => File(xfile.path))
                            .toList();

                        // 3. Appel à l'API
                        await photoApi.storePhoto(
                          titre: _titleCtrl.text,
                          description: _descCtrl.text,
                          region: _regionCtrl
                              .text, // C'est le nom de la région/ethnie
                          images: imageFiles,
                          publieParAdminId: adminId, // REMPLACER avec l'ID réel
                        );

                        // 4. Succès
                        Navigator.pop(context); // Fermer le dialogue
                        // Mise à jour de l'interface principale (si nécessaire)
                        // setState(() { ... });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Publication ajoutée avec succès !"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        // 5. Erreur
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Erreur lors de la publication : ${e.toString().split(':').last}",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        setStateDialog(
                          () => isLoading = false,
                        ); // Fin du chargement en cas d'erreur
                      } finally {
                        // Assurez-vous que l'état de chargement est désactivé si l'on reste dans la boîte de dialogue
                        if (Navigator.of(context).canPop()) {
                          setStateDialog(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      "Publier",
                      style: TextStyle(color: Colors.white),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Couleur d'action
              ),
            ),
          ],
        ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textSecondary,
            ),
            onPressed: () {
              if (_textCtrl.text.isNotEmpty) {
                setState(() {
                  proverbes.add({
                    'texte': _textCtrl.text,
                    'origine': _origCtrl.text,
                    'approuve': false,
                  });
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Le texte du proverbe est requis"),
                  ),
                );
              }
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textSecondary,
            ),
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
        _addImage(context);
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
        backgroundColor: AppColors.textSecondary,
        title: const Text(
          'Gestion Contenu Culturel',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.textSecondary,
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
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.textSecondary,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.textSecondary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.textSecondary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.textSecondary,
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

class _ImageDetailView extends StatefulWidget {
  final List<String> images;
  final String titre;
  final String description;
  final String ethnie;

  const _ImageDetailView({
    required this.images,
    required this.titre,
    required this.description,
    required this.ethnie,
  });

  @override
  State<_ImageDetailView> createState() => _ImageDetailViewState();
}

class _ImageDetailViewState extends State<_ImageDetailView> {
  int _currentPage = 0;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final img = widget.images[index];
              return img.startsWith('assets/')
                  ? Image.asset(img, fit: BoxFit.contain)
                  : Image.file(File(img), fit: BoxFit.contain);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 10 : 6,
              height: _currentPage == index ? 10 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.textSecondary
                    : Colors.white54,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.titre.isNotEmpty)
                Text(
                  widget.titre,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (widget.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.description,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              if (widget.ethnie.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: Text(
                    "Ethnie : ${widget.ethnie}",
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
