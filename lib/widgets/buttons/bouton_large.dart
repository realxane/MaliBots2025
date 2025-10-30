import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

ElevatedButton bouton_large({
  required String hint,
  required VoidCallback onPressed,
}) {
    return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      // maximumSize: Size(1000, 50),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    onPressed: onPressed,
                    child: Text(hint),
                  );
}