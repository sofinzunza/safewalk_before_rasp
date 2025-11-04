import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final String? leadingAsset;
  final double borderRadius;
  final Size minSize;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = KColors.tealChillon,
    this.foregroundColor = Colors.white,
    this.leadingAsset,
    this.borderRadius = 30,
    this.minSize = const Size(250, 48),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingAsset != null) ...[
            Image.asset(leadingAsset!, width: 22, height: 22),
            const SizedBox(width: 12),
          ],
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500, // Medium
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
