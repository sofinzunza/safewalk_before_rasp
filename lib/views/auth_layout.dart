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
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = LoadingPage();
            } else if (snapshot.hasData) {
              widget = const UserTypeRouter();
            } else {
              widget = pageIfNotConnected ?? const HomePage();
            }
            return widget;
          },
        );
      },
    );
  }
}
