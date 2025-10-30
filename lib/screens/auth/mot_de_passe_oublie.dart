import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/auth/cree_nouveau_motdepasse.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
// import 'package:malibots_challenge_eni/widgets/custum_button.dart';
// import 'package:malibots_challenge_eni/widgets/custum_textfileid.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';


import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';

class MotDePasseOublie extends StatelessWidget {
   MotDePasseOublie({super.key});
  final _emailrecuperationCtrl = TextEditingController(); // controller de l'email de recuperation de mot de passeCtrl

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Navigator.canPop(context)
            ? fleche_retour(onPressed: () {
              Navigator.pushNamed(context, AppRoutes.connecter);
            })
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60,),
          Center(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  child: Image.asset(  
                    AppImages.logo, height: 64,),
                ),
                  Column(
                    children: [
                    Text("Anw Ka Dembe",style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),),
                    // SizedBox(height: 0,),
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: Text("Découvrez l'âme du Mali",style: AppTextStyles.soustitre,),
                    ),
                  ])
              
            ]),
          ),
          SizedBox(height: 30,),
          Padding(
            padding:  EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.2),
            child: Text("Mot de passe oublié ?",style:TextStyle(
              fontSize: 25,
              color:AppColors.primary,
              fontWeight: FontWeight.bold
              )
              ),
          ),
          SizedBox(height: 30,),
          Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.07),
          child:Text("Entrez votre adresse email et nous \nvous enverrons un lien pour reinitialiser \nvotre mot de passe", style: AppTextStyles.soustitre,),
          ),
         SizedBox(height: 20,),

        TextField(
          controller: _emailrecuperationCtrl,
           keyboardType: TextInputType.emailAddress,
           textInputAction: TextInputAction.next,
          decoration: decor("Entrez votre adresse email"),
        
        ),
         SizedBox(height: 20,),
        //  CustomButton(text:"Envoyer le code",onPressed: (){
        //    Navigator.push(context, MaterialPageRoute(builder:(context)=> CreeNouveauMotdepasse()));
        //  },)
        SizedBox(
          width: double.infinity,
          child: bouton_large( hint:"Envoyer le code",onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder:(context)=> CreeNouveauMotdepasse()));
          },),
        ),
          
        ]),
      ),
    );
  }
}