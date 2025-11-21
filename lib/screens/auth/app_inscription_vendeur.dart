import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';
import 'package:malibots_challenge_eni/constants/app_images.dart';
import 'package:malibots_challenge_eni/controllers/userscontrollervendeur.dart';
import 'package:malibots_challenge_eni/models/uservendeur.dart';
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
  final _emailOrPhoneCtrl = TextEditingController(); // reste le même nom pour limiter les diff
  final _passwordCtrl = TextEditingController();
  final _cityRegionCtrl = TextEditingController();
  final _proPhoneCtrl = TextEditingController();     // Téléphone professionnel CONSERVÉ
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
            floating: true,
            snap: true,
            pinned: false,
            leading: Navigator.canPop(context)
                ? fleche_retour(onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.choixprofil);
                  })
                : null,
          ),

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

                  // Email requis (on garde le contrôleur, on clarifie le libellé)
                  TextField(
                    controller: _emailOrPhoneCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.white),
                    decoration: decor('E-mail'),
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

                  // Téléphone professionnel CONSERVÉ
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _accepted,
                        onChanged: (value) async {
                          if (value == true && !_accepted) {
                            bool? agree = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  "Conditions d’utilisation",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                content: const SizedBox(
                                  height: 300,
                                  child: SingleChildScrollView(
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
                                      backgroundColor: AppColors.primary,
                                    ),
                                    child: const Text(
                                      "Refuser",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                    ),
                                    child: const Text(
                                      "Accepter",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

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
                          style: TextStyle(fontSize: 14, color: Colors.brown),
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
                      onPressed: () async {
                        if (!_accepted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez accepter les conditions.')),
                          );
                          return;
                        }

                        // Validation e-mail (exigé)
                        final email = _emailOrPhoneCtrl.text.trim();
                        final isEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
                        if (!isEmail) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez saisir un e-mail valide.')),
                          );
                          return;
                        }

                        final controller = Userscontrollervendeur();

                        // Petit loader
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          final vendeur = await controller.registervendeur(
                            nom: _nameCtrl.text.trim(),
                            email: email, // on envoie bien "email"
                            motdepasse: _passwordCtrl.text.trim(),
                            region: _cityRegionCtrl.text.trim(),
                            telephone: _proPhoneCtrl.text.trim(),     // Téléphone (si attendu côté back)
                            telephonePro: _proPhoneCtrl.text.trim(),  // Téléphone professionnel conservé
                            savoirFaire: _savoirFaireCtrl.text.trim(),
                          );

                          if (context.mounted) {
                            Navigator.of(context).pop(); // ferme le loader
                            Navigator.pushReplacementNamed(context, AppRoutes.bienvenue_vendeur);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.of(context).pop(); // ferme le loader
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
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