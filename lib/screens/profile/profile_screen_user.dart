import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/text_button.dart';

class ProfileScreenUser extends StatelessWidget {
  const ProfileScreenUser({super.key});

  @override
  
  Widget build(BuildContext context) {
bool isSignaled = true; // pour savoir si le vendeur a été signalé
String reason = "Produit non conforme aux règles du marché"; // raison du signalement
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            children: [
              Center(
                child: ClipOval(
                  
                  child: Image.asset("assets/images/profil.jpeg",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,)
                  
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
               const Divider(color: AppColors.textfieldcolor,),
              _buildInfoRow("Tel :", "93 15 31 24"),
              const Divider(color: AppColors.textfieldcolor,),
              _buildInfoRow("Email :", "youss210.com@gmail.com"),
              const Divider(color: AppColors.textfieldcolor,),
              _buildInfoRow("Ville :", "koulikoro"),
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
                _buildInfoRow("Langue :","Francais"),
                Divider(color: AppColors.textfieldcolor,),
                _buildInfoRow("Theme :","Sombre"),
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
                  ),),
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
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
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
