import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/screens/profile/about_page.dart';
import 'package:malibots_challenge_eni/screens/profile/modifierprofile.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/text_button.dart';
import 'package:malibots_challenge_eni/providers/theme_store.dart';
import 'package:provider/provider.dart';
import 'modifierprofile.dart';

class ProfileScreenUser extends StatefulWidget {
  const ProfileScreenUser({super.key});

  @override
  State<ProfileScreenUser> createState() => _ProfileScreenUserState();
}

class _ProfileScreenUserState extends State<ProfileScreenUser> {
  String userName = "Youssouf Guindo";
  String userTag = "@Faso den gnouma";
  String imagePath = "assets/images/profil.jpeg";
  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: const Text("Voir le profil"),
              onTap: () {
                Navigator.pop(context);
                _showImagePreview();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text("Modifier le profil"),
              onTap: () async {
                Navigator.pop(context);
                // Aller à la page d'édition du profil
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Modifierprofile()),
                );

                //  Si l’utilisateur a modifié le profil
                if (result != null && result is Map) {
                  setState(() {
                    userName = result['name'] ?? userName;
                    if (result['image'] != null) {
                      imagePath = result['image'].path;
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

 void _showImagePreview() {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.black.withOpacity(0.9), // fond sombre semi-transparent
      insetPadding: EdgeInsets.zero, // supprime les marges autour du Dialog
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Hero(
          tag: 'profileImage',
          child: SizedBox.expand(
            child: InteractiveViewer( // permet de zoomer/dézoomer
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain, // garde les proportions
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
  @override
  
  Widget build(BuildContext context) {
bool isSignaled = true; // pour savoir si le vendeur a été signalé
String reason = "Produit non conforme aux règles du marché"; // raison du signalement

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Profil",textAlign: TextAlign.center,),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            children: [
              // Center(
              //   child: ClipOval(
                  
              //     child: Image.asset("assets/images/profil.jpeg",
              //     width: 100,
              //     height: 100,
              //     fit: BoxFit.cover,)
                  
              //     ),
              // ),
               // 👇 Image cliquable
              GestureDetector(
                onTap: _showProfileOptions,
                child: Stack(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        imagePath,
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
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15,),
              Text("Youssouf Guindo",style: AppTextStyles.titre1),
               Text("@Faso den gnouma",style: AppTextStyles.soustitre),
               SizedBox(height: 20,),
               Align(
                alignment: Alignment.centerLeft,
               child: Text("Informations personnelles",style: AppTextStyles.soustitre),),
               SizedBox(height: 8,),
               Divider(color: Theme.of(context).dividerColor,),
              _buildInfoRow("Tel :", "93 15 31 24"),
               Divider(color: Theme.of(context).dividerColor,),
              _buildInfoRow("Email :", "youss210.com@gmail.com"),
               Divider(color: Theme.of(context).dividerColor,),
              _buildInfoRow("Ville :", "koulikoro"),
               Divider(color: Theme.of(context).dividerColor,),
              const SizedBox(height: 25),
               Align(
                alignment: Alignment.centerLeft,
                child: Text("Mes paramètres",style: AppTextStyles.soustitre,)),
                const SizedBox(height: 10),
                Divider(color: Theme.of(context).dividerColor,),
                _buildInfoRow("Langue :","Francais"),
                Divider(color: Theme.of(context).dividerColor),
                _PreferencesThemeRow(),
                Divider(color: Theme.of(context).dividerColor),
                Align(
                  alignment: Alignment.center,
                  child:text_bouton( 
                    hint: "Déconnecter",
                    onPressed: (){}), 
                ),
                Divider(color: Theme.of(context).dividerColor,),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: bouton_large(
                    hint: "Modifier mon profil",
                    onPressed: (){

                       Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Modifierprofile(),
                      ),
                    );
                    },
                  ),),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: bouton_large(hint: "A props", onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  AboutAppPage(),
                        ),
                      );
                    }),
                    
                  ),
                  const SizedBox(height: 25),
          Padding(padding: EdgeInsets.all(10),
          child: ElevatedButton.icon(onPressed: (){
            if(isSignaled){
              showDialog(context: context, builder: (context)=>AlertDialog(
                title: Text("vous avez été signaler"),
                content: Text(reason),
                actions: [
                  TextButton( onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),)
                ],

              )
              
              );
            } else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Aucun signalement !"))
              );
            }
          },
          icon: Stack(
            children: [
              const Icon(Icons.flag),
               Positioned(
                right: 0,
                top: 0,
                child: Icon(Icons.circle_notifications,
                color: isSignaled ? Colors.red : Colors.transparent,
                size: 8,),
              ),
            ],
          ),
          label:Text("Signalement") ,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          ),
          ),
                




            ],
          ) ,
          ),
            ),
    );
  }
}

// Widget pour afficher une ligne d'information
  Widget _buildInfoRow(String label, String value) {
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher un bouton d'activité
  
class _PreferencesThemeRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeStore>().isDark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Thème sombre",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch(
            value: isDark,
            activeColor: AppColors.primary, // ton marron
            onChanged: (v) => context.read<ThemeStore>().toggle(v),
          ),
        ],
      ),
    );
  }
}
