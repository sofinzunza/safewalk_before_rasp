import 'package:flutter/material.dart';
import 'package:safewalk/data/notifiers.dart';
import 'package:safewalk/views/pages/change_password_page.dart';
import 'package:safewalk/views/pages/delete_account_page.dart';
import 'package:safewalk/views/pages/edit_profile_page.dart';
import 'package:safewalk/views/pages/start_page.dart';
import 'package:safewalk/views/auth_service.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: 15),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Cuenta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Keeps the title visually centered by matching the
                  // back button width. Adjust if you change the icon.
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 35),
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/O40.png',
                          height: 250,
                          width: 250,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    ListView(
                      shrinkWrap:
                          true, // Allows the ListView to take only necessary space
                      children: [
                        ListTile(
                          title: const Text('Editar perfil'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return EditProfilePage();
                                },
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Cambiar contraseña'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ChangePasswordPage();
                                },
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Eliminar cuenta'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return DeleteAccountPage();
                                },
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text('Cerrar sesión'),
                          textColor: Colors.red,
                          onTap: () async {
                            // Capture navigator before awaiting to avoid using the
                            // BuildContext across an async gap.
                            final navigator = Navigator.of(context);

                            // Ask for confirmation before logging out.
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Confirmar cierre de sesión',
                                  ),
                                  content: const Text(
                                    '¿Estás segura/o que deseas cerrar sesión?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text(
                                        'Cerrar sesión',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldLogout != true) return;

                            // Sign out using the shared AuthService so Firebase
                            // clears the persisted session.
                            await authService.value.signOut();
                            selectedPageNotifier.value = 0;
                            // Remove all routes and go to StartPage
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => StartPage()),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
