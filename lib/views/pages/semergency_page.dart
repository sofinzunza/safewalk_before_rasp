import 'package:flutter/material.dart';
import 'package:safewalk/views/pages/manage_emergency_contacts_page.dart';

class SettingsEmergencyContacts extends StatelessWidget {
  const SettingsEmergencyContacts({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirigir directamente a la nueva página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ManageEmergencyContactsPage()),
      );
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
