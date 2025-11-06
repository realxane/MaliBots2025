import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';
import 'photo_detail_page.dart';

class GaleriePage extends StatefulWidget {
  const GaleriePage({super.key});

  @override
  State<GaleriePage> createState() => _GaleriePageState();
}

class _GaleriePageState extends State<GaleriePage> {
  String selectedTheme = "Danse";
  String selectedSousTheme = "Tous";
  String searchQuery = "";

  final List<String> themes = ["Danse", "Mariage", "Baptême", "Événement"];
  final List<String> sousThemes = [
    "Tous",
    "Sonraï",
    "Bambara",
    "Tamacheq",
    "Dogon",
    "Minianka",
    "Malinké",
  ];

  final List<Map<String, dynamic>> photos = [
    {
      "titre": "Danse Bambara",
      "theme": "Danse",
      "sousTheme": "Bambara",
      "images": ["assets/danse1.jpg", "assets/danse2.jpg"],
      "description":
          "Une danse traditionnelle Bambara mettant en valeur la beauté et la force du mouvement.",
    },
    {
      "titre": "Danse Sonrai",
      "theme": "Danse",
      "sousTheme": "Sonraï",
      "images": ["assets/galerie/takamba1.jpg", "assets/galerie/takamba2.jpg"],
      "description":
          "Une danse traditionnelle Sonrai mettant en valeur la beauté et la force du mouvement.",
    },
    {
      "titre": "Mariage Sonrai",
      "theme": "Mariage",
      "sousTheme": "Sonraï",
      "images": ["assets/galerie/mariage.jpg"],
      "description":
          "Une danse traditionnelle Bambara mettant en valeur la beauté et la force du mouvement.",
    },
    {
      "titre": "Danse Soninké",
      "theme": "Danse",
      "sousTheme": "Sonraï",
      "images": ["assets/danse1.jpg"],
      "description":
          "Une danse culturelle Soninké exécutée lors des grandes cérémonies.",
    },
    {
      "titre": "Danse Minianka",
      "theme": "Danse",
      "sousTheme": "Minianka",
      "images": ["assets/danse1.jpg"],
      "description": "Danse Minianka pleine d’énergie et de joie.",
    },
  ];

  List<Map<String, dynamic>> get filteredPhotos {
    return photos.where((photo) {
      final matchTheme = photo["theme"] == selectedTheme;
      final matchSousTheme =
          selectedSousTheme == "Tous" ||
          photo["sousTheme"] == selectedSousTheme;
      final matchSearch = photo["titre"].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return matchTheme && matchSousTheme && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Galarie Photos',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.grid_view_rounded,
            color: AppColors.textSecondary,
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.accueil);
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications, color: Colors.brown),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildThemeSelector(),
            const SizedBox(height: 10),
            _buildSousThemeSelector(),
            const SizedBox(height: 10),
            Expanded(child: _buildPhotoGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (val) => setState(() => searchQuery = val),
      decoration: decor(
        'Recherche',
      ).copyWith(prefixIcon: const Icon(Icons.search, color: Colors.brown)),
    );
  }

  Widget _buildThemeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Thème", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedTheme,
          dropdownColor: Colors.white,
          style: const TextStyle(color: AppColors.primary),
          items: themes
              .map(
                (theme) => DropdownMenuItem(value: theme, child: Text(theme)),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedTheme = val!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSousThemeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sousThemes.map((sous) {
          final isSelected = sous == selectedSousTheme;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(sous),
              selected: isSelected,
              selectedColor: Colors.brown,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.brown,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (_) {
                setState(() {
                  selectedSousTheme = sous;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      itemCount: filteredPhotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return PhotoCard(photo: filteredPhotos[index]);
      },
    );
  }
}

class PhotoCard extends StatefulWidget {
  final Map<String, dynamic> photo;
  const PhotoCard({super.key, required this.photo});

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoDetailPage(photo: widget.photo),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      widget.photo["images"][0],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xB3000000),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 1.0,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              liked
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: liked ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                liked = !liked;
                              });
                            },
                          ),
                          const Text(
                            "10",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.photo["titre"],
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
