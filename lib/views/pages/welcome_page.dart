import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/views/pages/home_page.dart';
import 'package:safewalk/views/pages/swelcome_page.dart';
import 'package:safewalk/views/widgets/ble_button.dart';
import 'package:safewalk/views/widgets/nextbutton_widget.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Semantics(
                header: true,
                label: 'Bienvenido a SafeWalk',
                child: const Text(
                  'Bienvenido a SafeWalk!',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),
              Stack(alignment: Alignment.center, children: [BleButton()]),
              const SizedBox(height: 80),
              Semantics(
                label:
                    'Comencemos por enlazar tu gorro Navicap con la aplicación. Activa el Bluetooth de tu teléfono para conectarlo.',
                child: const Text(
                  'Comencemos por enlazar tu\ngorro Navicap con la aplicación,\nactiva el Bluetooth de tu teléfono\npara conectarlo.',
                  textAlign: TextAlign.center,
                  style: KtextStyle.descriptionText,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    button: true,
                    label: 'Omitir configuración de Bluetooth',
                    hint: 'Ir directamente a la pantalla principal',
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return HomePage();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Omitir',
                        style: TextStyle(
                          color: KColors.tealChillon,
                          decoration: TextDecoration.underline,
                          decorationColor: KColors.tealChillon,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  NextButton(
                    text: 'Siguiente',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SettingsWelcomePage();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
