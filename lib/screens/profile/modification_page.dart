import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/text_button.dart';

class ModificationPage extends StatefulWidget {
  const ModificationPage({super.key});

  @override
  State<ModificationPage> createState() => _ModificationPageState();
}

class _ModificationPageState extends State<ModificationPage> {
   File? _imageFile;
  final picker = ImagePicker();
  // Champs qu'on doit modifier
  final TextEditingController nameController = TextEditingController(text: "Youssouf Guindo");
  final TextEditingController usernameController = TextEditingController(text: "@Faso den gnouma");
  final TextEditingController emailController = TextEditingController(text: "youss210.com@gmail.com");
  final TextEditingController villeController = TextEditingController(text: "Koulikoro");
  final TextEditingController telController = TextEditingController(text: "93 15 31 24");
  // Choisir une image depuis la galerie
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Modifier mon profil", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            children: [
              // modification de la photo de profil

              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: Stack(
                    children: [ ClipOval(
                      
                      child:  _imageFile != null
                            ? Image.file(_imageFile!, width: 100, height: 100, fit: BoxFit.cover) 
                            : Image.asset("assets/images/profil.jpeg",
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,)
                      
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                 ] ),
                ),
              ),
              SizedBox(height: 15,),
              // Text("Youssouf Guindo",style: AppTextStyles.titre1),
              //  Text("@Faso den gnouma",style: AppTextStyles.soustitre),
              _buildTextField("modier", nameController),
              _buildTextField("modier", usernameController), 

               SizedBox(height: 20,),
               Align(
                alignment: Alignment.centerLeft,
               child: Text("Informations personnelles",style: AppTextStyles.soustitre),),
               SizedBox(height: 8,),
               const Divider(color: AppColors.textfieldcolor,),
              _buildInfoRow("Tel :", _buildTextField("modifer", telController)),
              const Divider(color: AppColors.textfieldcolor,),
              _buildInfoRow("Email :", _buildTextField("modifer", emailController)),
              const Divider(color: AppColors.textfieldcolor,),
              _buildInfoRow("Ville :", _buildTextField("modifer", villeController)),
              const Divider(color: AppColors.textfieldcolor,),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Mes activités",style: AppTextStyles.soustitre,)),
                const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActivityButton("Achats", (){}),
                  _ActivityButton("Favoris", (){}),
                  _ActivityButton("Avis", (){})
                            
                ],
              ),
              const SizedBox(height: 25),
               Align(
                alignment: Alignment.centerLeft,
                child: Text("Mes paramètres",style: AppTextStyles.soustitre,)),
                const SizedBox(height: 10),
                Divider(color: AppColors.textfieldcolor,),
                // _buildInfoRow("Langue :","Francais"),
                Divider(color: AppColors.textfieldcolor,),
                // _buildInfoRow("Theme :","Sombre"),
                Divider(color: AppColors.textfieldcolor,),
                Align(
                  alignment: Alignment.center,
                  child:text_bouton( 
                    hint: "Déconnecter",
                    onPressed: (){}), 
                ),
                Divider(color: AppColors.textfieldcolor,),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: bouton_large(
                    hint: "Modifier mon profil",
                    onPressed: (){},
                  ),)
                




            ],
          ) ,
          ),
            ),
    );
  }
}

// Widget pour afficher une ligne d'information
  Widget _buildInfoRow(String label, Widget valuetext ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(child: valuetext)

          
        ],
      ),
    );
  }

  // Widget pour afficher un bouton d'activité
  Widget _ActivityButton(String text, VoidCallback onpress) {
    return ElevatedButton(
      onPressed: onpress,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
         fixedSize: const Size(100, 45),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
      
     
      ),
      child: Text(
        text),
    );
  }
  Widget _buildTextField(String hint, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.textfieldcolor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),

          
        )
      ),
    );
  }