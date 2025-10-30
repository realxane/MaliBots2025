import 'package:flutter/material.dart';

import 'package:malibots_challenge_eni/screens/auth/cree_nouveau_motdepasse.dart';
import 'package:malibots_challenge_eni/screens/auth/mot_de_passe_oublie.dart';
import 'package:malibots_challenge_eni/screens/home/home_screen.dart';
import 'package:malibots_challenge_eni/screens/onboarding/onboarding_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/home_screen.dart';

import 'package:malibots_challenge_eni/screens/auth/app_google_apple.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:malibots_challenge_eni/routes/app_routes.dart';
import 'package:malibots_challenge_eni/screens/auth/app_choixprofil.dart';
import 'package:malibots_challenge_eni/screens/auth/app_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anw ka Dambe',
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
      // home:MotDePasseOublie() ,
    );
  }
}
