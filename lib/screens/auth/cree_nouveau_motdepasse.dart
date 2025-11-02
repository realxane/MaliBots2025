import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';
import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';

class CreeNouveauMotdepasse extends StatefulWidget {
  const CreeNouveauMotdepasse({super.key});

  @override
  State<CreeNouveauMotdepasse> createState() => _CreeNouveauMotdepasseState();
}

class _CreeNouveauMotdepasseState extends State<CreeNouveauMotdepasse> {
  final _newmotdepass=TextEditingController();

  bool _obscure1=true;
  bool _obscure2=true;
  final _newmotdepassconfirmation=TextEditingController();

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
              Navigator.pushNamed(context, AppRoutes.forgotPassword);
            })
            : null,
      ),
      body:SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.08, // marge adaptative
            vertical: height * 0.04,),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const SizedBox(height: 60,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                  height: height * 0.12,
                  width: height * 0.12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child:  Image.asset(  
                    AppImages.logo),
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
                    // SizedBox(height: 0,),
                    Padding(
                      padding:  EdgeInsets.only(left: 40),
                      child: Text("Découvrez l'âme du Mali",style: AppTextStyles.soustitre.copyWith(
                          fontSize: width * 0.035,
                        ),),
                    ),
                  ])
              
            ]),
            SizedBox(height: height * 0.06),            
            Text("Créer un nouveau mot de passe et accéder à votre compte",
            style:TextStyle(
              fontSize: 18,
              color:AppColors.primary,
              fontWeight: FontWeight.bold
              
              ),
              textAlign: TextAlign.left,
              ),
             SizedBox(height: height * 0.03,),
            Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.23),
           child:  Text("Entrez votre nouveau mot de passe pour sécuriser et accéder à votre compte", style: AppTextStyles.soustitre.copyWith(
                          fontSize: width * 0.045,
                        ),
              textAlign: TextAlign.left,
              ),
            ),
           SizedBox(height: height * 0.04),
          //  const CustumTextfileid(label:"mot de passe",hint:"Entrez votre nouveau mot de passe",),
          TextField(
            controller: _newmotdepass,
            obscureText: _obscure1,
             textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white),
            decoration: decor("Entrez votre nouveau mot de passe").copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure1 = !_obscure1),
                        icon: Icon(
                          _obscure1 ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                      ),
                    ),
          
          ),
            SizedBox(height: height * 0.03,),
          //  const CustumTextfileid(label:"confirmer",hint:"confirmer votre nouveau mot de passe",),
          TextField(
            controller: _newmotdepassconfirmation,
            obscureText: _obscure2,
             textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white),
            decoration: decor("confirmer votre nouveau mot de passe").copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                        icon: Icon(
                          _obscure2 ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                      ),
                    ),
          
          ),
            SizedBox(height: height * 0.03,),
          //  CustomButton(text:"Confirmer",onPressed: (){},)
          SizedBox(
            width: double.infinity,
            child: bouton_large(hint:"Confirmer",onPressed: (){},)),
            
          ]),
        ),
      ) ,
    );
  }
}