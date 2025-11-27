import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/views/widgets/buttomimage_widget.dart';
import 'package:safewalk/views/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _currentEmail = '';
  String _currentPhone = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    // Cargar datos actuales del usuario
    final user = authService.value.currentUser;
    if (user != null) {
      _currentEmail = user.email ?? '';
      _emailCtrl.text = _currentEmail;

      // Cargar teléfono desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _currentPhone = prefs.getString('user_phone') ?? '';
      _phoneCtrl.text = _currentPhone;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    // Validar formulario primero
    if (!_formKey.currentState!.validate()) return;

    final emailText = _emailCtrl.text.trim();
    final phoneText = _phoneCtrl.text.trim();
    final passwordText = _passwordCtrl.text.trim();

    // Verificar si hay cambios
    final emailChanged = emailText.isNotEmpty && emailText != _currentEmail;
    final phoneChanged = phoneText.isNotEmpty && phoneText != _currentPhone;

    if (!emailChanged && !phoneChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay cambios para actualizar'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    // Si va a cambiar el email, requerir contraseña
    if (emailChanged && passwordText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes ingresar tu contraseña para cambiar el correo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = authService.value.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      List<String> updatedFields = [];

      // Actualizar email
      if (emailChanged) {
        // Reautenticar usuario antes de cambiar email
        final credential = EmailAuthProvider.credential(
          email: _currentEmail,
          password: passwordText,
        );
        await user.reauthenticateWithCredential(credential);

        // Ahora sí actualizar el email
        await user.verifyBeforeUpdateEmail(emailText);

        updatedFields.add('correo electrónico');
      }

      // Actualizar teléfono en SharedPreferences
      if (phoneChanged) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_phone', phoneText);
        updatedFields.add('teléfono');
      }

      if (mounted) {
        String message =
            'Se actualizó exitosamente: ${updatedFields.join(' y ')}';
        if (emailChanged) {
          message += '\n\nSe envió un correo de verificación a $emailText';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta';
          break;
        case 'email-already-in-use':
          errorMessage = 'Este correo ya está en uso';
          break;
        case 'invalid-email':
          errorMessage = 'Correo electrónico inválido';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Por seguridad, debes cerrar sesión y volver a iniciar';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  // Header: back button at left, centered title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Volver',
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Editar Cuenta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/O46.png',
                        height: 230,
                        width: 230,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _dec('Ingrese su nuevo correo electrónico'),
                    validator: (v) {
                      // Solo validar si hay contenido
                      if (v != null && v.isNotEmpty && !v.contains('@')) {
                        return 'Formato de correo inválido';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _dec('Ingrese su nuevo número de teléfono'),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: (v) {
                      // Solo validar si hay contenido
                      if (v != null && v.isNotEmpty && v.trim().length < 8) {
                        return 'Teléfono debe tener al menos 8 dígitos';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText:
                          'Contraseña actual (requerida para cambiar email)',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
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
                        borderSide: const BorderSide(
                          color: KColors.tealChillon,
                          width: 1.5,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 140),
                  CustomButton(
                    text: _isLoading ? 'Actualizando...' : 'Actualizar',
                    onPressed: _isLoading
                        ? () {} // Botón deshabilitado pero funcional
                        : () => _updateProfile(),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
