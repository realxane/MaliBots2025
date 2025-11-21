import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malibots_challenge_eni/api/usercontroller.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';

class Modifierprofile extends StatefulWidget {
  const Modifierprofile({super.key});

  @override
  State<Modifierprofile> createState() => _ModifierprofileState();
}

class _ModifierprofileState extends State<Modifierprofile> {
  File? _imageFile;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController =
      TextEditingController();
  final controller=ProfileController();
  bool _loading = false;
  bool _isloadprofile=true;
  @override
void initState() {
  super.initState();
  _loadUser();
}
Future<void> _loadUser() async {
     try {
    final user = await controller.getProfile();
    if (!mounted) return; // Vérifie que le widget est encore actif

    setState(() {
      _nameController.text = user?['nom'] ?? '';
      _imageUrl = user?['image_path'];
      _isloadprofile = false;
    });
  } catch (e) {
    setState(() {
      _isloadprofile = false;
    });
    debugPrint("Erreur lors du chargement du profil: $e");
  }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _chooseImageSource() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Prendre une photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choisir depuis la galerie"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _loading = true);
    // final name = _nameController.text.trim();
    final result = await controller.updateProfile(
    nom: _nameController.text.trim(),
    image: _imageFile,
  );
   setState(() => _loading = false);

    if (result['success']) {
    Navigator.pop(context, {
      'name': result['user']['nom'],
      'image': result['user']['image_path'],
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur: ${result['error']}")),
    );
  }
  }



  @override
  Widget build(BuildContext context) {
    if (_isloadprofile) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Navigator.canPop(context)
            ? fleche_retour(onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profil_user);
            })
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            GestureDetector(
              onTap: _chooseImageSource,
              child: Center(
                child: Stack(
                  children: [
                    ClipOval(
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ) 
                          : (_imageUrl != null && _imageUrl!.isNotEmpty) 
                            ? Image.network('http://10.236.139.1:8000/storage/profile_images/$_imageUrl',
                          height: 100,width:
                           100,fit: 
                           BoxFit.cover,)
                           : Image.asset(
                            "assets/images/profil.jpeg",
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                         ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
              fillColor: AppColors.textfieldcolor,
                filled: true,
                // labelText: "Nom complet",
                hintStyle: const TextStyle(
               color: Colors.white70,
                fontWeight: FontWeight.w500,
      ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),  
       focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),              
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child:bouton_large(hint: "Enregistrer les modifications", onPressed: _saveChanges), 
            ),
          ],
        ),
      ),
    );
  }
}
