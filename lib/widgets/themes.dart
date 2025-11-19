// theme.dart (version CardThemeData)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

const Color bogolan = AppColors.primary;

ThemeData buildLightTheme() {
  final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
  final cs = ColorScheme.fromSeed(seedColor: bogolan, brightness: Brightness.light);
  final csWhite = cs.copyWith(
    surface: Colors.white,
    background: Colors.white,
  );
  return base.copyWith(
    colorScheme: csWhite,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: csWhite.onSurface,
      elevation: 0,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    dividerColor: AppColors.textSecondary,
    cardTheme: CardThemeData( 
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: cs.primary,
      unselectedItemColor: cs.onSurfaceVariant,
      backgroundColor: cs.surface,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  final cs = ColorScheme.fromSeed(seedColor: bogolan, brightness: Brightness.dark);
  return base.copyWith(
    colorScheme: cs,
    scaffoldBackgroundColor: cs.background,
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).apply(bodyColor: cs.onSurface, displayColor: cs.onSurface),
    dividerColor: cs.outlineVariant,
    cardTheme: CardThemeData( 
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: cs.primary,
      unselectedItemColor: cs.onSurfaceVariant,
      backgroundColor: cs.surface,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}