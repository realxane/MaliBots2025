import 'package:flutter/material.dart';
import 'package:malibots_challenge_eni/constants/app_colors.dart';

class CustumTextfileid extends StatelessWidget {
  final String label;
  final String hint;
  const CustumTextfileid({super.key, required this.label, required this.hint});


  @override
  Widget build(BuildContext context) {
    return SizedBox(
       width: MediaQuery.of(context).size.width * 0.9, // 80% de la largeur de l’écran
      height: 60,
      child: TextField(
        
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          
          ),
          fillColor: AppColors.primary,
          filled: true
          
        ),
      ),
    );
  }
}