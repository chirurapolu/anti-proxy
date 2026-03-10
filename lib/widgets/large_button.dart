import 'package:flutter/material.dart';

class LargeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const LargeButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }
}
