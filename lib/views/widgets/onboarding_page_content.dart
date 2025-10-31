import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String description;
  final String bgImage;
  final String fgImage;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.description,
    required this.bgImage,
    required this.fgImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(bgImage, height: 380, fit: BoxFit.contain),
            Image.asset(fgImage, height: 310, fit: BoxFit.contain),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: KtextStyle.descriptionText,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
