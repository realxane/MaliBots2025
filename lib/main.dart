import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:malibots_challenge_eni/screens/auth/cree_nouveau_motdepasse.dart';
import 'package:malibots_challenge_eni/screens/auth/mot_de_passe_oublie.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/home_screen.dart';
=======
import 'package:malibots_challenge_eni/screens/auth/app_google_apple.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/auth/app_choixprofil.dart';
import 'package:malibots_challenge_eni/screens/auth/app_login.dart';
>>>>>>> Bassirou

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anw ka Dambe',
<<<<<<< HEAD
      // initialRoute: '/onboarding',
=======
      initialRoute: '/onboarding',
>>>>>>> Bassirou
      // routes: {
      //   '/onboarding': (context) => const OnboardingScreen(),
      //   '/home': (context) => const HomeScreen(),
      // },
<<<<<<< HEAD
      home:MotDePasseOublie() ,
=======
      routes: {
        AppRoutes.accueil: (context) => const HomeScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.choixprofil: (context) => const ChoixProfilPage(),
        AppRoutes.connecter: (context) => const Login(),
        AppRoutes.authGoogleApple: (context) => const AuthGoogleApple(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Login(),
>>>>>>> Bassirou
    );
  }
}
