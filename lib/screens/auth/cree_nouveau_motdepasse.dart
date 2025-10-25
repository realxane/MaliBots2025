import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
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
                    "assets/images/logo_appli.png",),
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
              color:AppColors.primary,
              fontWeight: FontWeight.bold
              ),
              ),
          ),
          const SizedBox(height: 30,),
          Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.23),
         child:  Text("Entrez votre nouveau mot de\npasse pour sécuriser et\naccéder à votre compte", style: AppTextStyles.soustitre,),
          ),
         const SizedBox(height: 20,),
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
         const SizedBox(height: 20,),
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
         const SizedBox(height: 20,),
        //  CustomButton(text:"Confirmer",onPressed: (){},)
        bouton_large(hint:"Confirmer",onPressed: (){},),
          
        ]),
      ) ,
    );
  }
}