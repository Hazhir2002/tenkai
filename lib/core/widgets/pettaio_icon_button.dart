import 'package:flutter/material.dart';

class PettaioIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const PettaioIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(40),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(65), width: 1),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
