import 'package:flutter/material.dart';

class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const SocialIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.all(14),
      ),
      onPressed: onPressed,
      child: Icon(icon, color: color, size: 22),
    );
  }
}
