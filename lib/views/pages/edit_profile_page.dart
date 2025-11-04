import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/views/widgets/buttomimage_widget.dart';
import 'package:safewalk/views/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() {
    // Cargar datos actuales del usuario
    final user = authService.value.currentUser;
    if (user != null) {
      _emailCtrl.text = user.email ?? '';
      // El teléfono se puede cargar desde Firestore o SharedPreferences si lo tienes guardado
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    // Validar formulario primero
    if (!_formKey.currentState!.validate()) return;

    // Validar que al menos un campo esté lleno
    final emailText = _emailCtrl.text.trim();
    final phoneText = _phoneCtrl.text.trim();

    if (emailText.isEmpty && phoneText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes completar al menos un campo para actualizar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = authService.value.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      bool hasUpdates = false;
      List<String> updatedFields = [];

      // Actualizar email solo si está lleno y es diferente al actual
      if (emailText.isNotEmpty && emailText != user.email) {
        await user.verifyBeforeUpdateEmail(emailText);
        hasUpdates = true;
        updatedFields.add('correo electrónico');
      }

      // Actualizar teléfono solo si está lleno (aquí puedes agregar Firestore)
      if (phoneText.isNotEmpty) {
        hasUpdates = true;
        updatedFields.add('teléfono');
      }

      if (mounted) {
        if (hasUpdates) {
          String message =
              'Se actualizó exitosamente: ${updatedFields.join(' y ')}';
          if (updatedFields.contains('correo electrónico')) {
            message += '\n(Revisa tu email para verificar el nuevo correo)';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay cambios para actualizar'),
              backgroundColor: Colors.blue,
            ),
          );
        }
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
                  const SizedBox(height: 180),
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
