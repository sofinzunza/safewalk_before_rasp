// lib/views/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/views/auth_service.dart';
import 'package:safewalk/views/google_auth.dart';
import 'package:safewalk/views/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safewalk/views/pages/recover_password.dart';
import 'package:safewalk/views/pages/signin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: KColors.tealChillon, width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const Text(
                'Inicio de sesión',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/S39.png',
                    height: 300,
                    fit: BoxFit.contain,
                    width: 600,
                  ),
                  Image.asset(
                    'assets/images/43.png',
                    height: 280,
                    fit: BoxFit.contain,
                    width: 300,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec('Ingrese su correo electrónico'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: _dec('Ingrese su contraseña').copyWith(
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return RecoverPassword();
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: KColors.tealChillon,
                      decoration: TextDecoration.underline,
                      decorationColor: KColors.tealChillon,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final email = _emailCtrl.text.trim();
                    final password = _passCtrl.text;

                    // simple client-side validation
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ingrese correo y contraseña'),
                        ),
                      );
                      return;
                    }

                    // attempt sign in
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    try {
                      await authService.value.signIn(
                        email: email,
                        password: password,
                      );
                      // on success, navigate to HomePage (auth listener may also handle this)
                      if (!mounted) return;
                      navigator.pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    } on FirebaseAuthException catch (e) {
                      final msg = e.message ?? 'Error al iniciar sesión';
                      if (!mounted) return;
                      messenger.showSnackBar(SnackBar(content: Text(msg)));
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Error inesperado')),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: KColors.tealChillon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Ingresar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Aún no tienes una cuenta? ',
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SigninPage()),
                      );
                    },
                    child: const Text(
                      'Regístrate aquí',
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

              const SizedBox(height: 10),
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('o', style: TextStyle(color: Colors.black54)),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialCircleButton(
                    asset: 'assets/images/Apple.png',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Apple próximamente')),
                      );
                    },
                  ),
                  const SizedBox(width: 28),
                  _SocialCircleButton(
                    asset: 'assets/images/Google.png',
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      bool result = await FirebaseServices().signInWithGoogle();
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón circular con imagen (foto) centrada
class _SocialCircleButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const _SocialCircleButton({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Image.asset(asset, width: 32, height: 32, fit: BoxFit.contain),
      ),
    );
  }
}
