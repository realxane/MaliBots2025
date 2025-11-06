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
    final taill_sreen=MediaQuery.of(context).size;
   final width = taill_sreen.width;
    final height = taill_sreen.height;
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.08, // marge adaptative
            vertical: height * 0.04,),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            SizedBox(height: height * 0.05),            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                 height: height * 0.12,
                  width: height * 0.12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(  
                    AppImages.logo, height: 64,),
                ),
                  SizedBox(width: width * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("Anw Ka Dembe",style: TextStyle(
                       fontSize: width * 0.06,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),),
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text("Découvrez l'âme du Mali",style: AppTextStyles.soustitre.copyWith(
                          fontSize: width * 0.036,
                        ),),
                    ),
                  ])
              
            ]),
            SizedBox(height: height * 0.06),            
               Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(
                    fontSize: width * 0.06,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
             SizedBox(height: height * 0.03),
             Text(
                "Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.",
                style: AppTextStyles.soustitre.copyWith(
                  fontSize: width * 0.045,
                ),
                textAlign: TextAlign.center,
              ),
           SizedBox(height: height * 0.04),

          
          TextField(
            controller: _emailrecuperationCtrl,
             keyboardType: TextInputType.emailAddress,
             textInputAction: TextInputAction.next,
            decoration: decor("Entrez votre adresse email"),
          
          ),
            SizedBox(height: height * 0.05),
          SizedBox(
            width: double.infinity,
            child: bouton_large( hint:"Envoyer le code",onPressed: (){
              Navigator.pushNamed(context, AppRoutes.newPassword);
            },),
          ),
            
          ]),
        ),
      ),
    );
  }
}