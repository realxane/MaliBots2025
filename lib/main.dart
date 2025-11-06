import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/data/list_product.dart';
import 'package:malibots_challenge_eni/providers/favoris_store.dart';
import 'package:malibots_challenge_eni/providers/product_store.dart';
import 'package:malibots_challenge_eni/screens/admins/app_admin_dashboard.dart';
import 'package:malibots_challenge_eni/screens/admins/drawerpage.dart';
import 'package:malibots_challenge_eni/screens/admins/app_liste_culture.dart';
import 'package:malibots_challenge_eni/screens/admins/app_liste_produits.dart';
import 'package:malibots_challenge_eni/screens/admins/app_liste_users.dart';
import 'package:malibots_challenge_eni/screens/admins/app_liste_vendeurs.dart';

import 'package:malibots_challenge_eni/screens/auth/cree_nouveau_motdepasse.dart';
import 'package:malibots_challenge_eni/screens/auth/mot_de_passe_oublie.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_catalog_screen.dart';
import 'package:malibots_challenge_eni/screens/catalogue/app_panier.dart';
//import 'package:malibots_challenge_eni/screens/catalogue/app_produit_detail.dart';
import 'package:malibots_challenge_eni/screens/home/home_screen.dart';
import 'package:malibots_challenge_eni/screens/onboarding/onboarding_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/home_screen.dart';
import 'package:malibots_challenge_eni/screens/auth/app_google_apple.dart';

// import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/auth/app_choixprofil.dart';
import 'package:malibots_challenge_eni/screens/auth/app_login.dart';
import 'package:malibots_challenge_eni/screens/musiques/musique_screen.dart';
import 'package:malibots_challenge_eni/screens/auth/app_inscription.dart';
import 'package:malibots_challenge_eni/screens/auth/app_inscription_vendeur.dart';
import 'package:malibots_challenge_eni/screens/paiements/choix_mode.dart';
import 'package:provider/provider.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/auth/app_choixprofil.dart';
import 'package:malibots_challenge_eni/screens/auth/app_login.dart';
import 'package:malibots_challenge_eni/screens/musiques/musique_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              ProductsStore(kProducts), // ta liste initiale de Product
        ),
        ChangeNotifierProvider(create: (_) => FavoritesStore()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anw ka Dambe',
      // initialRoute: AppRoutes.admin_dash,
      initialRoute: AppRoutes.onboarding,
      routes: {
        AppRoutes.accueil: (context) => MainScreen(),
        // AppRoutes.accueil: (context) => const HomeScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.choixprofil: (context) => const ChoixProfilPage(),
        AppRoutes.connecter: (context) => const Login(),
        AppRoutes.authGoogleApple: (context) => const AuthGoogleApple(),
        AppRoutes.inscrire: (context) => InscriptionPage(),
        AppRoutes.inscrire_vendeur: (context) => InscriptionVendeurPage(),
        AppRoutes.forgotPassword: (context) => MotDePasseOublie(),
        AppRoutes.newPassword: (context) => CreeNouveauMotdepasse(),
        AppRoutes.musique: (context) => const MusiqueScreen(),
        AppRoutes.catalogue: (context) => const CatalogScreen(),
        AppRoutes.panier: (context) => const CartPage(),
        AppRoutes.admin_dash: (context) => const AdminDashboardPage(),
        AppRoutes.choixmodepayemnt: (context) => const PaymentScreen(),

        AppRoutes.adminListeUsers: (context) => const UserListPage(),
        AppRoutes.adminListeVendeurs: (context) => const VendeursListePage(),
        AppRoutes.adminListeProduits: (context) => const ProduitsListePage(),
        AppRoutes.adminListeCultures: (context) => const CulturesListePage(),
        AppRoutes.adminprofile: (context) => const MonDrawer(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home:MonDrawer() ,
    );
  }
}
