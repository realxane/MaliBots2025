import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:malibots_challenge_eni/firebase_options.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:malibots_challenge_eni/providers/product_store.dart';
import 'package:malibots_challenge_eni/data/list_product.dart';

import 'package:malibots_challenge_eni/screens/admins/app_admin_dashboard.dart';
import 'package:malibots_challenge_eni/screens/admins/adminprofil.dart';
import 'package:malibots_challenge_eni/screens/admins/app_liste_culture.dart';
import 'package:malibots_challenge_eni/screens/admins/app_liste_produits.dart';
import 'package:malibots_challenge_eni/screens/admins/app_liste_users.dart';
import 'package:malibots_challenge_eni/screens/admins/app_liste_vendeurs.dart';

import 'package:malibots_challenge_eni/screens/auth/app_bienvenue_acheteur.dart';
import 'package:malibots_challenge_eni/screens/auth/app_bienvenue_vendeur.dart';
import 'package:malibots_challenge_eni/screens/auth/cree_nouveau_motdepasse.dart';
import 'package:malibots_challenge_eni/screens/auth/mot_de_passe_oublie.dart';
import 'package:malibots_challenge_eni/screens/auth/app_google_apple.dart';
import 'package:malibots_challenge_eni/screens/auth/app_choixprofil.dart';
import 'package:malibots_challenge_eni/screens/auth/app_login.dart';
import 'package:malibots_challenge_eni/screens/auth/app_inscription.dart';
import 'package:malibots_challenge_eni/screens/auth/app_inscription_vendeur.dart';

import 'package:malibots_challenge_eni/screens/catalogue/app_catalog_screen.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_panier.dart';
import 'package:malibots_challenge_eni/screens/catalogue/catalog_controller.dart';

import 'package:malibots_challenge_eni/screens/home/home_screen.dart';
import 'package:malibots_challenge_eni/screens/onboarding/onboarding_screen.dart';
import 'package:malibots_challenge_eni/screens/profile/profile_screen_user.dart';
import 'package:malibots_challenge_eni/screens/musiques/musique_screen.dart';
import 'package:malibots_challenge_eni/screens/paiements/choix_mode.dart';

import 'package:malibots_challenge_eni/widgets/themes.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/providers/theme_store.dart';

import 'services/produit_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider<ProduitService>(
          create: (_) => ProduitService(),
        ),
        ChangeNotifierProvider<CatalogController>(
          create: (ctx) => CatalogController(
            ctx.read<ProduitService>(),
          ),
        ),
        ChangeNotifierProvider<FavoritesStore>(
          create: (_) => FavoritesStore(),
        ),
        ChangeNotifierProvider<ThemeStore>(
          create: (_) => ThemeStore(),
        ),
        // ChangeNotifierProvider<ProductsStore>(
        //   create: (_) => ProductsStore(kProducts),
        // ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeStore>(
      builder: (context, themeStore, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Anw ka Dambe',
          // initialRoute: AppRoutes.onboarding,
          initialRoute: AppRoutes.admin_dash,
          routes: {
            AppRoutes.accueil: (context) => const MainScreen(),
            AppRoutes.onboarding: (context) => const OnboardingScreen(),
            AppRoutes.choixprofil: (context) => const ChoixProfilPage(),
            AppRoutes.connecter: (context) => const Login(),
            AppRoutes.authGoogleApple: (context) => const AuthGoogleApple(),
            AppRoutes.inscrire: (context) => InscriptionPage(),
            AppRoutes.inscrire_vendeur: (context) => InscriptionVendeurPage(),
            AppRoutes.forgotPassword: (context) => MotDePasseOublie(),
            AppRoutes.musique: (context) => const MusiqueScreen(),
            AppRoutes.catalogue: (context) => const CatalogScreen(),
            AppRoutes.panier: (context) => const CartPage(),

            // Admin
            AppRoutes.admin_dash: (context) => const AdminDashboardPage(),
            AppRoutes.adminListeUsers: (context) => const UserListPage(),
            AppRoutes.adminListeVendeurs: (context) =>
                const VendeursListePage(),
            AppRoutes.adminListeProduits: (context) =>
                const ProduitsListePage(),
            AppRoutes.adminListeCultures: (context) =>
                const CulturesListePage(),
            AppRoutes.adminprofile: (context) => const adminprofile(),

            // Paiement
            AppRoutes.choixmodepayemnt: (context) => const PaymentScreen(),

            // Profils
            AppRoutes.profil_vendeur: (context) => ProfileScreenUser(),
            AppRoutes.profil_user: (context) => ProfileScreenUser(),

            // Bienvenue
            AppRoutes.bienvenue_acheteur: (context) =>
                const BienvenueAcheteur(),
            AppRoutes.bienvenue_vendeur: (context) =>
                const BienvenueVendeur(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.newPassword) {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => CreeNouveauMotdepasse(
                  token: args["token"],
                  email: args["email"],
                ),
              );
            }
            return null;
          },
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeStore.mode,
        );
      },
    );
  }
}