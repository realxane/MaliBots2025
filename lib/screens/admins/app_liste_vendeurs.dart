import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/screens/admins/app_users_details.dart'; // Réutilisation de la page UserDetailPage

class VendeursListePage extends StatefulWidget {
  const VendeursListePage({super.key});

  @override
  State<VendeursListePage> createState() => _VendeursListePageState();
}

class _VendeursListePageState extends State<VendeursListePage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> vendeurs = [
  {
    'name': 'Bassirou Dramé',
    'email': 'bassirou@example.com',
    'password': '123456',
    'city': 'Bamako',
    'preferences': ['Tenue traditionnelle', 'Cuisine'],
    'image': 'assets/img1.jpg',
  },
  {
    'name': 'Alassane Sow',
    'email': 'alassane@example.com',
    'password': 'abcdef',
    'city': 'Kayes',
    'preferences': ['Accessoires'],
    'image': 'assets/img2.jpg',
  },
  {
    'name': 'Vieux Maiga',
    'email': 'vieux@example.com',
    'password': 'maiga2025',
    'city': 'Mopti',
    'preferences': ['Cuisine'],
    'image': 'assets/img3.jpg',
  },
  {
    'name': 'Youssouf Guindo',
    'email': 'youssouf@example.com',
    'password': 'guindo789',
    'city': 'Sikasso',
    'preferences': ['Tenue traditionnelle', 'Accessoires'],
    'image': 'assets/img4.jpg',
  },
  {
    'name': 'Nana S Keita',
    'email': 'nana@example.com',
    'password': 'nanaPass',
    'city': 'Ségou',
    'preferences': ['Cuisine', 'Accessoires'],
    'image': 'assets/img5.jpg',
  },
  {
    'name': 'Oumou Maliki Tembely',
    'email': 'oumou@example.com',
    'password': 'tembely2025',
    'city': 'Bamako',
    'preferences': ['Tenue traditionnelle'],
    'image': null,
  },
  {
    'name': 'Fatouma Sow',
    'email': 'fatouma@example.com',
    'password': 'fatouma123',
    'city': 'Kayes',
    'preferences': ['Cuisine'],
    'image': null,
  },
  {
    'name': 'Guedjouma Diabate',
    'email': 'guedjouma@example.com',
    'password': 'diabate456',
    'city': 'Mopti',
    'preferences': ['Tenue traditionnelle', 'Accessoires'],
    'image': 'assets/img7.jpg',
  },
  {
    'name': 'Abdoul Wayab',
    'email': 'abdoul@example.com',
    'password': 'abdoulpass',
    'city': 'Tombouctou',
    'preferences': ['Cuisine'],
    'image': 'assets/img8.jpg',
  },
  {
    'name': 'Oumar Diarra',
    'email': 'oumar@example.com',
    'password': 'oumar123',
    'city': 'Gao',
    'preferences': ['Tenue traditionnelle'],
    'image': 'assets/img9.jpg',
  },
];


  String query = '';

  @override
  Widget build(BuildContext context) {
    final filteredVendeurs = vendeurs
        .where((v) =>
            v['name'].toLowerCase().contains(query.toLowerCase()) ||
            v['email'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Gestion des vendeurs',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Champ de recherche
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un vendeur...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            // Titre
            const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Vendeurs List",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            // Liste des vendeurs
            Expanded(
              child: ListView.builder(
                itemCount: filteredVendeurs.length,
                itemBuilder: (context, index) {
                  final vendeur = filteredVendeurs[index];

                  return Card(
                    color: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      onTap: () {
                        // Affiche la vue statique par défaut
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailPage(user: vendeur),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        backgroundImage: vendeur['image'] != null
                            ? AssetImage(vendeur['image']) as ImageProvider
                            : null,
                        child: vendeur['image'] == null
                            ? const Icon(Icons.person,
                                color: AppColors.primary, size: 30)
                            : null,
                      ),
                      title: Text(
                        vendeur['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        vendeur['email'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'Voir') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailPage(user: vendeur),
                              ),
                            );
                          } else if (value == 'Modifier') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailPage(user: vendeur, isEditable: true),
                              ),
                            );
                          } else if (value == 'Supprimer') {
                            setState(() => vendeurs.remove(vendeur));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('${vendeur['name']} supprimé')),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'Voir',
                            child: Row(
                              children: [
                                Icon(Icons.visibility,
                                    color: AppColors.primary),
                                SizedBox(width: 10),
                                Text('Voir profil'),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
