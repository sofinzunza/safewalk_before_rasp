import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:safewalk/views/pages/home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/views/pages/login_page.dart';
import 'package:safewalk/views/pages/signin_email.dart';
import 'package:safewalk/views/google_auth.dart';

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const Text(
                'Registrarse',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Fondo + persona superpuestos (simple)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/S39.png',
                    height: 320,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    'assets/images/43.png',
                    height: 320,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Elige con que registrarte:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Términos + Política (en una sola línea con enlaces)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Al crear una cuenta, aceptas nuestros ',
                      ),
                      TextSpan(
                        text: 'Términos',
                        style: const TextStyle(
                          color: KColors.tealChillon,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => openUrl(
                            'https://drive.google.com/file/d/1K3bOpRdvmGXtnkguWU_2fiLeXt7MbGfd/view',
                          ),
                      ),
                      const TextSpan(text: ' y confirmas haber leído nuestra '),
                      TextSpan(
                        text: 'Política de privacidad',
                        style: const TextStyle(
                          color: KColors.tealChillon,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => openUrl(
                            'https://drive.google.com/file/d/1uoCtbWP51qCe6wrVS62WNjadWCNuOyry/view',
                          ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Apple + Google simétricos
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Apple.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Apple',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        // Capture context-dependent objects before the async gap
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);

                        bool result = await FirebaseServices()
                            .signInWithGoogle();
                        if (result) {
                          navigator.pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Error al Registrarse con Google'),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Google.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Continuar con correo (funciona)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SigninEmailPage();
                        },
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: KColors.tealChillon,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/correo.png',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Continuar con Correo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes una cuenta? ',
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
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
                      'Ingresa aquí',
                      style: TextStyle(
                        color: KColors.tealChillon,
                        decoration: TextDecoration.underline,
                        decorationColor: KColors.tealChillon,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
