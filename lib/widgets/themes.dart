import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

const Color bogolan = AppColors.primary;

ThemeData buildLightTheme() {
  final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: bogolan,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    dividerColor: AppColors.textSecondary,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: bogolan,
      unselectedItemColor: Colors.brown[300],
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: bogolan,
      brightness: Brightness.dark,
    ).copyWith(
      background: Colors.black,
      surface: const Color(0xFF111111),
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    dividerColor: AppColors.textSecondary,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: bogolan,
      unselectedItemColor: Colors.brown[300],
      backgroundColor: Colors.black,
      type: BottomNavigationBarType.fixed,
    ),
  );
}