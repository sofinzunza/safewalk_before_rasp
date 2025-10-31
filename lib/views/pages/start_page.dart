import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/views/pages/login_page.dart';
import 'package:safewalk/views/pages/onboarding_carousel.dart';
import 'package:safewalk/views/widgets/custombutton_widget.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 45),
              const Text(
                'SafeWalk',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu compañero de movilidad:\nseguro, inteligente y accesible.',
                style: KtextStyle.descriptionText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/S17.png', // fondo verde claro
                    height: 400,
                    width: 500,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    'assets/images/50.png', // personaje
                    height: 310,
                    width: 310,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const Spacer(),
              CustomButton(
                text: 'Comienza ya',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return OnboardingCarousel();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginPage();
                      },
                    ),
                  );
                },
                child: const Text(
                  'o Inicia sesión',
                  style: TextStyle(
                    color: KColors.tealChillon,
                    decoration: TextDecoration.underline,
                    decorationColor: KColors.tealChillon,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
