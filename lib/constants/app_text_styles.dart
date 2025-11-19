import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Titres
  static const TextStyle titre1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle titre2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Sous-titres
  static const TextStyle soustitre = TextStyle( 
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Texte normal
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.primary,
  );

  // Boutons
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
}
