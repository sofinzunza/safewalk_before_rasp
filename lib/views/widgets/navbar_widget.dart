import 'package:flutter/material.dart';
import 'package:safewalk/data/notifiers.dart';
// Page navigation is handled by HomePage via `selectedPageNotifier`.
// Navbar only updates the selected index now, so we don't import pages here.

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_active_rounded),
              label: 'Alertas',
            ),
            NavigationDestination(
              icon: Icon(Icons.sos_rounded),
              label: 'Emergencia',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: 'Configuración',
            ),
          ],
          onDestinationSelected: (value) {
            // Just update the selected page so the HomePage can swap its body
            // and keep the navbar visible on all pages.
            selectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
