import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/screens/profile/articles.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/text_button.dart';

class ProfileScrennVendeur extends StatefulWidget {
  const ProfileScrennVendeur({super.key});

  @override
  State<ProfileScrennVendeur> createState() => _ProfileScrennVendeurState();
}
 class _ProfileScrennVendeurState extends State<ProfileScrennVendeur> {
  final List<Articles> articles = [
  Articles(nom: "chemise en bogolan",
   imagepath: "assets/images/chemise.png",
    likes: 3, 
    rating: 3.5),
    Articles(nom: "sac en cuir",
   imagepath: "assets/images/sac.png",
    likes: 10,
    rating: 4.5),
   
 ];

  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  width: double.infinity,
                  child: bouton_large(
                    hint: "Modifier mon profil",
                    onPressed: (){},
                  ),),
              const SizedBox(height: 25),
               Align(
                alignment: Alignment.centerLeft,
                child: Text("Mes Articles",style: AppTextStyles.soustitre,)),
                const SizedBox(height: 10),
               GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: articles.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 0.7,
  ),
  itemBuilder: (context, index) {
    final article = articles[index];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + like
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.asset(
                  article.imagepath,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        article.likes.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(article.nom,style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
            ),),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: List.generate(5, (starIndex) {
                return Icon(
                  starIndex < article.rating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
          ),
        ],
      ),
    );
  },
)
               
                
                




            ],
          ) ,
          ),
            ),
    );
  }
}
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
