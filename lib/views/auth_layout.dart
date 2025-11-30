import 'package:flutter/material.dart';
import 'package:safewalk/views/auth_service.dart';
import 'package:safewalk/views/pages/home_page.dart';
import 'package:safewalk/views/pages/user_type_router.dart';
import 'package:safewalk/views/pages/loading_page.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            // Si hay datos (usuario autenticado), mostrar página correspondiente
            if (snapshot.hasData) {
              return const UserTypeRouter();
            }

            // Si ya terminó de cargar y no hay usuario, mostrar página de login
            if (snapshot.connectionState != ConnectionState.waiting) {
              return pageIfNotConnected ?? const HomePage();
            }

            // Solo mostrar loading en el primer inicio (cuando no hay datos previos)
            return const LoadingPage();
          },
        );
      },
    );
  }
}
