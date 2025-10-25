import 'package:flutter/material.dart';
TextButton text_bouton({
  required String hint,
  required VoidCallback onPressed
  }) {
    return TextButton(
                      onPressed: onPressed,
                      child: Text(hint),
                    );
}