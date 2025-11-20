import 'package:flutter/material.dart';
TextButton text_bouton( {
  required String hint,
  required VoidCallback onPressed
  }) {
    return TextButton(
            onPressed: onPressed,
            child: Text(hint),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(14, 66, 109, 1),
            ),
          );
} 