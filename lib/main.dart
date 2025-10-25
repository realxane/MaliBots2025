import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/screens/auth/cree_nouveau_motdepasse.dart';
import 'package:malibots_challenge_eni/screens/auth/mot_de_passe_oublie.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/home_screen.dart';

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
      // initialRoute: '/onboarding',
      // routes: {
      //   '/onboarding': (context) => const OnboardingScreen(),
      //   '/home': (context) => const HomeScreen(),
      // },
      home:MotDePasseOublie() ,
    );
  }
}
