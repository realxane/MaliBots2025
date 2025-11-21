import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/api/adminapicontroller.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/screens/admins/app_users_details.dart'; // Réutilisation de la page UserDetailPage

class VendeursListePage extends StatefulWidget {
  const VendeursListePage({super.key});

  @override
  State<VendeursListePage> createState() => _VendeursListePageState();
}

class _VendeursListePageState extends State<VendeursListePage> {
  final TextEditingController _searchController = TextEditingController();
   String query = '';
  late Future<Map<String, dynamic>> _futureUsers; // ⚡ nouvelle version
  final userController = Adminapicontroller();
 @override
  void initState() {
    super.initState();
    _futureUsers = userController.getUsersByRole("Vendeur"); // ⚡ récupère Map
  }
Widget _buildUserCard(Map<String, dynamic> user) {
    final image = user['image_path'];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailPage(user: user),
          ),
        );
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
            backgroundImage: image != null
                ? NetworkImage("http://0.0.0.0:8000/storage/$image")
                : null,
            child: image == null
                ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                : null,
          ),
          title: Text(
            user['nom'] ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(
            user['email'] ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'Voir') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailPage(user: user, isEditable: false),
                  ),
                );
              } else if (value == 'Modifier') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailPage(user: user, isEditable: true),
                  ),
                );
              } else if (value == 'Supprimer') {
                setState(() {
                  _futureUsers = _futureUsers.then((data) {
                    data['users'].removeWhere((u) => u['id'] == user['id']);
                    data['total'] = data['users'].length;
                    return data;
                  });
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user['nom']} supprimé')),
                );
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
                "Users List",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _futureUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!["users"].isEmpty) {
                    return const Center(child: Text('Aucun utilisateur trouvé'));
                  }

                  final users = snapshot.data!["users"] as List;
                  final filteredUsers = users.where((user) {
                    final nameLower = user['nom'].toString().toLowerCase();
                    final emailLower = user['email'].toString().toLowerCase();
                    final searchLower = query.toLowerCase();
                    return nameLower.contains(searchLower) ||
                        emailLower.contains(searchLower);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) => _buildUserCard(filteredUsers[index]),
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
