import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

class UserDetailPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isEditable;

  const UserDetailPage({super.key, required this.user, this.isEditable = false});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _cityController;
  List<String> preferences = [];
  final List<String> allPreferences = ['Tenue traditionnelle', 'Cuisine', 'Accessoires'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name'] ?? '');
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _passwordController = TextEditingController(text: widget.user['password'] ?? '');
    _cityController = TextEditingController(text: widget.user['city'] ?? '');
    preferences = widget.user['preferences'] != null
        ? List<String>.from(widget.user['preferences'])
        : [];
  }

  Widget _buildLineDetail(String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label :',
              style: TextStyle(color: AppColors.primary, fontSize: 16),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4), // Réduit l’espace entre les barres
        Divider(color: AppColors.primary, thickness: 0.5),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: widget.isEditable
          ? TextField(
              controller: controller,
              obscureText: isPassword,
              style: const TextStyle(color: AppColors.primary),
              decoration: InputDecoration(
                labelText: '$label :',
                labelStyle: const TextStyle(color: AppColors.primary),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : _buildLineDetail(label, controller.text),
    );
  }

  Widget _buildPreferencesStatic() {
    if (preferences.isEmpty) return const SizedBox.shrink();
    String prefText = preferences.join(', '); // Liste séparée par virgules
    return _buildLineDetail("Préférences", prefText);
  }

  Widget _buildPreferenceOption(String value) {
    return widget.isEditable
        ? CheckboxListTile(
            title: Text(value, style: const TextStyle(color: AppColors.primary)),
            value: preferences.contains(value),
            activeColor: AppColors.primary,
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  preferences.add(value);
                } else {
                  preferences.remove(value);
                }
              });
            },
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.isEditable ? "Modifier l'utilisateur" : "Détails utilisateur"),
      //   backgroundColor: AppColors.primary,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: (widget.user['image'] != null && widget.user['image'] != "")
                  ? AssetImage(widget.user['image'])
                  : null,
              child: (widget.user['image'] == null || widget.user['image'] == "")
                  ? const Icon(Icons.person, size: 70, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(height: 30),

            // Infos utilisateur
            _buildTextField('Nom complet', _nameController),
            _buildTextField('Email', _emailController),
            _buildTextField('Mot de passe', _passwordController, isPassword: true),
            _buildTextField('Ville', _cityController),
            const SizedBox(height: 20),

            // Préférences
            if (!widget.isEditable) _buildPreferencesStatic(),
            if (widget.isEditable)
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Préférences",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 16)),
              ),
            if (widget.isEditable) const SizedBox(height: 8),
            if (widget.isEditable) ...allPreferences.map((pref) => _buildPreferenceOption(pref)),

            const SizedBox(height: 30),

            if (widget.isEditable)
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("${_nameController.text} modifié !")));
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
