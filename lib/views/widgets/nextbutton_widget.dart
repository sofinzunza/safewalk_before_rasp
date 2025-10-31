import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';

class NextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const NextButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: KColors.tealChillon,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward),
        ],
      ),
    );
  }
}
