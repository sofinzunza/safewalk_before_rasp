// lib/views/pages/signin_email.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/models/user_model.dart';
import 'package:safewalk/data/services/firestore_service.dart';
import 'package:safewalk/views/auth_service.dart';
import 'package:safewalk/views/pages/welcome_page.dart';
import 'package:safewalk/views/pages/thome_page.dart';
import 'package:safewalk/views/widgets/custombutton_widget.dart';
import 'package:flutter/services.dart';

class SigninEmailPage extends StatefulWidget {
  const SigninEmailPage({super.key});

  @override
  State<SigninEmailPage> createState() => _SigninEmailPageState();
}

class _SigninEmailPageState extends State<SigninEmailPage> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _rutCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  String _checkboxError = '';

  bool _visuallyImpaired = false;
  bool _emergencyContact = false;
  bool? isChecked = false;
  bool isSwitched = false;
  double sliderValue = 0.0;

  // Deprecated: live _isValid getter removed (we now validate on submit with Form)

  bool _validateRut(String rut) {
    rut = rut.replaceAll('.', '').replaceAll('-', '');
    if (rut.length < 2) return false;
    final body = rut.substring(0, rut.length - 1);
    final dv = rut.substring(rut.length - 1).toUpperCase();

    if (!RegExp(r'^\d+$').hasMatch(body)) return false;

    int sum = 0;
    int multiplier = 2;
    for (int i = body.length - 1; i >= 0; i--) {
      sum += int.parse(body[i]) * multiplier;
      multiplier = multiplier == 7 ? 2 : multiplier + 1;
    }
    int mod = 11 - (sum % 11);
    String expectedDv;
    if (mod == 11) {
      expectedDv = '0';
    } else if (mod == 10) {
      expectedDv = 'K';
    } else {
      expectedDv = mod.toString();
    }
    return dv == expectedDv;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _rutCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // RUT formatter will be applied directly on the TextField via inputFormatters.
  void register() async {
    try {
      final userCredential = await authService.value.createAccount(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      final user = userCredential.user;
      if (user != null) {
        // Actualizar el display name
        await user.updateDisplayName(_nameCtrl.text.trim());
        await user.reload();

        // Crear perfil en Firestore
        final userType = _visuallyImpaired
            ? UserType.visuallyImpaired
            : UserType.emergencyContact;

        final userModel = UserModel(
          uid: user.uid,
          email: _emailCtrl.text.trim().toLowerCase(),
          name: _nameCtrl.text.trim(),
          rut: _rutCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          userType: userType,
          createdAt: DateTime.now(),
        );

        await firestoreService.createUserProfile(userModel);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro exitoso')));

      // Navegar según el tipo de usuario
      if (_visuallyImpaired) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomePage()),
        );
      } else {
        // Usuario es contacto de emergencia (tutor)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TwelcomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Hubo un error';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al crear perfil: $e';
      });
    }
  }

  void _onContinuePressed() {
    // Validate the form fields; validators will show inline errors.
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      setState(() {
        errorMessage = 'Por favor corrige los errores en el formulario';
      });
      return;
    }

    // require at least one of the two checkboxes
    if (!_visuallyImpaired && !_emergencyContact) {
      setState(() {
        _checkboxError = 'Debes seleccionar una opción';
      });
      return;
    }

    // Clear previous error and attempt register
    setState(() {
      errorMessage = '';
    });
    register();
  }

  void popPage() {
    Navigator.pop(context);
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

  // _RutInputFormatter will be placed at file top-level (below) to avoid nesting

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                'Regístrese con\nCorreo Electrónico',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontFamily: "DMSans",
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Regístrate a SafeWalk para una experiencia\npersonalizada con tu gorro Navicap.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        'assets/images/S27.png',
                        width: 1000,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _dec('Ingrese su correo electrónico'),
                          validator: (v) {
                            if (v == null || !v.contains('@')) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: _dec('Ingrese su nombre'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Ingrese su nombre';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _rutCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: _dec('Ingrese su rut'),
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9kK.\-]'),
                            ),
                            _RutInputFormatter(),
                          ],
                          validator: (v) {
                            if (v == null || !_validateRut(v.trim())) {
                              return 'RUT inválido';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _dec('Ingrese su número de teléfono'),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().length < 9) {
                              return 'Teléfono inválido';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: _dec('Introduzca la contraseña'),
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Es usuario con discapacidad visual o de\ncontacto de emergencia?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _visuallyImpaired,
                onChanged: (v) {
                  setState(() {
                    _visuallyImpaired = v ?? false;
                    if (_visuallyImpaired) {
                      _emergencyContact = false; // desmarca el otro
                    }
                    // clear checkbox error when user chooses an option
                    _checkboxError = '';
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text('Soy usuario con discapacidad visual'),
              ),
              CheckboxListTile(
                value: _emergencyContact,
                onChanged: (v) {
                  setState(() {
                    _emergencyContact = v ?? false;
                    if (_emergencyContact) {
                      _visuallyImpaired = false;
                    }
                    _checkboxError = '';
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text('Soy contacto de emergencia'),
              ),
              const SizedBox(height: 8),
              if (_checkboxError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _checkboxError,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Continuar',
                  onPressed: _onContinuePressed,
                ),
              ),
              const SizedBox(height: 24),
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}

// Top-level RUT formatter implementation
class _RutInputFormatter extends TextInputFormatter {
  static final _invalidChars = RegExp(r'[^0-9kK]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String raw = newValue.text;
    // strip dots and dashes
    raw = raw.replaceAll('.', '').replaceAll('-', '');
    // remove invalid chars (keep digits and k/K)
    raw = raw.replaceAll(_invalidChars, '');

    // limit to max 9 characters (8 body digits + 1 check digit)
    if (raw.length > 9) raw = raw.substring(0, 9);

    if (raw.isEmpty) {
      return const TextEditingValue(text: '');
    }

    if (raw.length == 1) {
      // only one char so far (can't format)
      return TextEditingValue(
        text: raw,
        selection: TextSelection.collapsed(offset: raw.length),
      );
    }

    final body = raw.substring(0, raw.length - 1);
    final dv = raw.substring(raw.length - 1);

    // insert thousands separator (dots) into body, from left to right
    List<String> parts = [];
    String remaining = body;
    while (remaining.length > 3) {
      parts.insert(0, remaining.substring(remaining.length - 3));
      remaining = remaining.substring(0, remaining.length - 3);
    }
    if (remaining.isNotEmpty) parts.insert(0, remaining);
    final formattedBody = parts.join('.');

    final formatted = '$formattedBody-$dv';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
