import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  String query = '';

  // Liste d'utilisateurs
  List<Map<String, dynamic>> users = [
    {'name': 'Bassirou Dramé', 'email': 'bassirou@example.com', 'image': 'assets/img1.jpg'},
    {'name': 'Alassane Sow', 'email': 'alassane@example.com', 'image': 'assets/img2.jpg'},
    {'name': 'Vieux Maiga', 'email': 'vieux@example.com', 'image': 'assets/img3.jpg'},
    {'name': 'Youssouf Guindo', 'email': 'youssouf@example.com', 'image': 'assets/img4.jpg'},
    {'name': 'Nana S Keita', 'email': 'nana@example.com', 'image': 'assets/img5.jpg'},
    {'name': 'Oumou Maliki Tembely', 'email': 'oumou@example.com', 'image': null},
    {'name': 'Fatouma Sow', 'email': 'fatouma@example.com', 'image': null},
    {'name': 'Guedjouma Diabate', 'email': 'guedjouma@example.com', 'image': 'assets/img7.jpg'},
    {'name': 'Abdoul Wayab', 'email': 'abdoul@example.com', 'image': 'assets/img8.jpg'},
    {'name': 'Oumar Diarra', 'email': 'oumar@example.com', 'image': 'assets/img9.jpg'},
  ];

  // Construction de la carte utilisateur (cliquable)
  Widget _buildUserCard(Map<String, dynamic> user) {
    return InkWell(
      onTap: () {
        // Action lors du clic sur la carte
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Profil de ${user['name']}')));
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            backgroundImage: user['image'] != null ? AssetImage(user['image']) : null,
            child: user['image'] == null
                ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                : null,
          ),
          title: Text(
            user['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(
            user['email'],
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'Voir') {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Profil de ${user['name']}')));
              } else if (value == 'Modifier') {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Modifier ${user['name']}')));
              } else if (value == 'Supprimer') {
                setState(() => users.remove(user));
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('${user['name']} supprimé')));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Voir',
                child: Row(
                  children: [
                    Icon(Icons.visibility, color: AppColors.primary),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrage selon la recherche
    final filteredUsers = users.where((user) {
      final nameLower = user['name'].toLowerCase();
      final emailLower = user['email'].toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) || emailLower.contains(searchLower);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Gestion des utilisateurs',
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
                hintText: 'Rechercher un utilisateur...',
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
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "User List",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Liste des utilisateurs
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) => _buildUserCard(filteredUsers[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
