import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

class VendeursListePage extends StatefulWidget {
  const VendeursListePage({super.key});

  @override
  State<VendeursListePage> createState() => _VendeursListePageState();
}

class _VendeursListePageState extends State<VendeursListePage> {
  final TextEditingController _searchController = TextEditingController();

  // Exemple de liste de vendeurs
  List<Map<String, dynamic>> users = [
    {
      'name': 'Bassirou Dramé',
      'email': 'bassirou@example.com',
      'image': 'assets/img1.jpg',
    },
    {
      'name': 'Alassane Sow',
      'email': 'alassane@example.com',
      'image': 'assets/img2.jpg',
    },
    {
      'name': 'Vieux Maiga',
      'email': 'vieux@example.com',
      'image': 'assets/img3.jpg',
    },
    {
      'name': 'Youssouf Guindo',
      'email': 'youssouf@example.com',
      'image': 'assets/img4.jpg',
    },
    {
      'name': 'Nana S Keita',
      'email': 'nana@example.com',
      'image': 'assets/img5.jpg',
    },
    {
      'name': 'Oumou Maliki Tembely',
      'email': 'oumou@example.com',
      'image': null,
    },
    {
      'name': 'Fatouma Sow',
      'email': 'fatouma@example.com',
      'image': null,
    },
    {
      'name': 'Guedjouma Diabate',
      'email': 'guedjouma@example.com',
      'image': 'assets/img7.jpg',
    },
    {
      'name': 'Abdoul Wayab',
      'email': 'abdoul@example.com',
      'image': 'assets/img8.jpg',
    },
    {
      'name': 'Oumar Diarra',
      'email': 'oumar@example.com',
      'image': 'assets/img9.jpg',
    },
  ];

  String query = '';

  @override
  Widget build(BuildContext context) {
    // Filtrage selon la recherche
    final filteredUsers = users
        .where((user) =>
            user['name'].toLowerCase().contains(query.toLowerCase()) ||
            user['email'].toLowerCase().contains(query.toLowerCase()))
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

            // Titre "Vendeurs List"
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
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];

                  return Card(
                    color: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      onTap: () {
                        // Effet cliquable simple (comme pour les users)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Détails de ${user['name']}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        backgroundImage: user['image'] != null
                            ? AssetImage(user['image']) as ImageProvider
                            : null,
                        child: user['image'] == null
                            ? const Icon(Icons.person,
                                color: AppColors.primary, size: 30)
                            : null,
                      ),
                      title: Text(
                        user['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        user['email'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'Voir') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Profil de ${user['name']}')),
                            );
                          } else if (value == 'Modifier') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Modifier ${user['name']}')),
                            );
                          } else if (value == 'Supprimer') {
                            setState(() {
                              users.remove(user);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('${user['name']} supprimé')),
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
