import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';

class adminprofile extends StatelessWidget {
  const adminprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Profil',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
          
              // Partie du haut avec l'avatar et les infos
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage("assets/images/profil.jpeg"),
                      // child: Icon(
                      //   Icons.person,
                      //   color: Colors.white,
                      //   size: 40,
                      // ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bonjour, youssouf",
                      style: AppTextStyles.titre2
                    ),
                    SizedBox(height: 5),
                    Text(
                      "youss210.com@gmail.com",
                      style: AppTextStyles.body
                    ),
                  ],
                ),
              ),
          
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: bouton_large(hint: "Acceuil", onPressed: (){
                  Navigator.pushNamed(context, AppRoutes.admin_dash);

                }
                )
                ),
              // const SizedBox(height: 15),
              // SizedBox(
              //   width: double.infinity,
              //   child: bouton_large(hint: "Profil", onPressed: (){
              //     // Navigator.pushNamed(context, AppRoutes.profil);
              //   })
              //   ),
              const SizedBox(height: 15),
              SizedBox(width: double.infinity,
              child: bouton_large(hint: "Deconnexion", onPressed: (){})
              ),
            ],
          ),
        ),
    );
  }

}