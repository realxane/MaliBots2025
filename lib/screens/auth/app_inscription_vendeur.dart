import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_large.dart';
import 'package:malibots_challenge_eni/widgets/buttons/bouton_retour.dart';
import 'package:malibots_challenge_eni/widgets/text_fields/text_field_decor.dart';

class InscriptionVendeurPage extends StatefulWidget {
  const InscriptionVendeurPage({super.key});

  @override
  State<InscriptionVendeurPage> createState() => _InscriptionVendeurPageState();
}

class _InscriptionVendeurPageState extends State<InscriptionVendeurPage> {

  final _nameCtrl = TextEditingController();
  final _emailOrPhoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _cityRegionCtrl = TextEditingController();
  final _proPhoneCtrl = TextEditingController();
  final _savoirFaireCtrl = TextEditingController();

  bool _accepted = false;
  bool _obscurePwd = true;

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
                        color: AppColors.primary,
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

                    TextField(
                      controller: _proPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: decor('Téléphone professionnel'),
                    ),
                    const SizedBox(height: 18),

                    // Section savoir-faire
                    const Text(
                      'Parlez-nous de votre savoir-faire',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _savoirFaireCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: decor('Écrivez ici'),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 12),

                    // Conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _accepted,
                          onChanged: (v) => setState(() => _accepted = v ?? false),
                          activeColor: AppColors.textSecondary,
                          checkColor: Colors.white,
                          side: const BorderSide(color: AppColors.textSecondary),
                        ),
                        const Expanded(
                          child: Text(
                            "J'accepte les conditions et je m'engage",
                            style: TextStyle(fontSize: 13, color: AppColors.primary),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez accepter les conditions.')),
                            );
                            return;
                          }
                          // if (_formKey.currentState?.validate() ?? false) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(content: Text('Compte en cours de création...')),
                          //   );
                          // }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bas de page
                    const Text(
                      'petit à petit, la culture se partage',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
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