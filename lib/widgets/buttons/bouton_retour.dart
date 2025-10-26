import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

IconButton fleche_retour({
  required VoidCallback onPressed
  }) {
    return IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.textSecondary, 
                onPressed: onPressed,
                tooltip: 'Retour',
              );
}