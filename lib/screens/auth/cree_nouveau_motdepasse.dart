import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/widgets/custum_button.dart';
import 'package:malibots_challenge_eni/widgets/custum_textfileid.dart';

class CreeNouveauMotdepasse extends StatelessWidget {
  const CreeNouveauMotdepasse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body:SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60,),
          Center(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  child:  Image.asset(  
                    "assets/images/icone.jpeg",),
                ),
                  const Column(
                    children: [
                    Text("Anw Ka Dembe",style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),),
                    // SizedBox(height: 0,),
                    Padding(
                      padding:  EdgeInsets.only(left: 50),
                      child: Text("Découvrez l'âme du Mali",style: AppTextStyles.soustitre,),
                    ),
                  ])
              
            ]),
          ),
          const SizedBox(height: 30,),
          Padding(
            padding:  EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.15),
            child: Text("Créer un nouveau mot de passe\nde passe et accéder à\nvotre compte",
            style:TextStyle(
              fontSize: 18,
              color:Color(0XFF904321),
              fontWeight: FontWeight.bold
              ),
              ),
          ),
          const SizedBox(height: 30,),
          Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.23),
         child:  Text("Entrez votre nouveau mot de\npasse pour sécuriser et\naccéder à votre compte", style: AppTextStyles.soustitre,),
          ),
         const SizedBox(height: 20,),
         const CustumTextfileid(label:"mot de passe",hint:"Entrez votre nouveau mot de passe",),
         const SizedBox(height: 20,),
         const CustumTextfileid(label:"confirmer",hint:"confirmer votre nouveau mot de passe",),
         const SizedBox(height: 20,),
         CustomButton(text:"Confirmer",onPressed: (){},)
          
        ]),
      ) ,
    );
  }
}