import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/controllers/acheteurcontrooler.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';
import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {

  final _nameCtrl = TextEditingController();
  final _emailOrPhoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _cityRegionCtrl = TextEditingController();
  final _proPhoneCtrl = TextEditingController();
  final _savoirFaireCtrl = TextEditingController();

  bool _accepted = false;
  bool _obscurePwd = true;

   // Liste des options sélectionnées pour la culture
  List<String> _selectedCultures = [];

  final List<String> _cultureOptions = ['Tenues', 'Accessoires', 'Cuisines'];


  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailOrPhoneCtrl.dispose();
    _passwordCtrl.dispose();
    _cityRegionCtrl.dispose();
    _proPhoneCtrl.dispose();
    _savoirFaireCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            floating: true, // réapparaît dès qu'on remonte
            snap: true,     // apparition "snappy"
            pinned: false,  // peut disparaître complètement en scroll descendant
            leading: Navigator.canPop(context)
                ? fleche_retour(onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.choixprofil);
                  })
                : null,
          ),

          // Contenu de la page
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        AppImages.logo,
                        height: 64,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Titre
                    const Text(
                      'Bienvenue sur Anw ka Dambe !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sous-titre
                    const Text(
                      'Inscrivez-vous',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Champs
                    TextField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: decor('Nom complet'),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _emailOrPhoneCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: decor('E-mail ou Téléphone'),
                    ),
                    const SizedBox(height: 12),

                    // Mot de passe
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePwd,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: decor('Mot de passe').copyWith(
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                          icon: Icon(
                            _obscurePwd ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _cityRegionCtrl,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: decor('Ville/Région'),
                    ),
                    const SizedBox(height: 12),


                    // Section savoir-faire
                    const Text(
                      'Qu\'aimez vous dans notre culture ?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),

                   
                                          Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _cultureOptions.map((option) {
                                  final isSelected = _selectedCultures.contains(option);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: _buildCultureChip(
                                      option,
                                      isSelected,
                                      () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedCultures.remove(option);
                                          } else {
                                            _selectedCultures.add(option);
                                          }
                                        });
                                      },
                                      AppColors.primary,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),


                    const SizedBox(height: 12),

                    // Conditions
                 Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _accepted,
                onChanged: (value) async {
                  if (value == true && !_accepted) {
                    // Affiche la boîte de dialogue avant de cocher
                    bool? agree = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Conditions d’utilisation", style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.textSecondary)),
                        content: SizedBox(
                          height: 300,
                          child: const SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "• Vous acceptez de fournir des informations exactes et véridiques lors de votre inscription.",
                                  style: TextStyle(fontSize: 15, height: 1.5),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "• Vous vous engagez à respecter les règles et valeurs de la communauté Anw ka Dambe.",
                                  style: TextStyle(fontSize: 15, height: 1.5),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "• Vous reconnaissez que toute utilisation abusive de la plateforme peut entraîner une suspension ou une suppression de votre compte.",
                                  style: TextStyle(fontSize: 15, height: 1.5),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "• Vos données personnelles seront protégées et traitées conformément à notre politique de confidentialité.",
                                  style: TextStyle(fontSize: 15, height: 1.5),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "• En cliquant sur « Accepter », vous confirmez avoir lu, compris et accepté l’ensemble de ces conditions.",
                                  style: TextStyle(fontSize: 15, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.primary
                            ),
                            child: const Text("Refuser",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary),
                            child: const Text("Accepter",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                          ),
                        ],
                      ),
                    );

                    // Si l’utilisateur accepte
                    if (agree == true) {
                      setState(() => _accepted = true);
                    }
                  } else {
                    setState(() => _accepted = false);
                  }
                },
                activeColor: Colors.brown,
              ),
              const Expanded(
                child: Text(
                  "J’accepte les conditions d’utilisation",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ],
          ),

                    const SizedBox(height: 8),

                    // Bouton
                    SizedBox(
                      height: 48,
                      child: bouton_large(
                        hint: 'Créer mon compte',
                        onPressed: () {
                         if (!_accepted) {
                            // L’utilisateur n’a pas accepté
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez accepter les conditions.')),
                            );
                            return;
                             // on sort ici pour bloquer la navigation
                          }
                             final controller=Acheteurcontrooler();
                             try {
                               
                             
                          controller.registeracheteur(
                            nom: _nameCtrl.text,
                            emailOrPhone: _emailOrPhoneCtrl.text,
                            motdepasse: _passwordCtrl.text,
                            region: _cityRegionCtrl.text,
                            telephone: _emailOrPhoneCtrl.text,
                          );
                          Navigator.pushNamed(context, AppRoutes.accueil);
                          } catch (e){ ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                            content: Text(
                        e.toString().replaceAll('Exception: ', ''),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                               ),
                 );
                          }
                          
                          // ✅ L’utilisateur a accepté, on peut aller à la page d’accueil
                          // if (_formKey.currentState?.validate() ?? false) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(content: Text('Compte en cours de création...')),
                          //   );
                          // }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

        
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget utilitaire pour les boutons de sélection (Chips)
Widget _buildCultureChip(
  String label,
  bool selected,
  VoidCallback onSelected,
  Color color,
) {
  return ActionChip(
    label: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
    backgroundColor: selected ? color : color.withOpacity(0.7),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    elevation: 0,
    onPressed: onSelected,
  );
}
