import 'package:flutter/material.dart';
import 'package:safewalk/views/pages/account_page.dart';
import 'package:safewalk/views/pages/language_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Configuración',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Center(
              child: Image.asset(
                'assets/images/O72.png',
                width: 220,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Cuenta'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AccountPage();
                          },
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Notificaciones'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificaciones')),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Lenguaje'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LanguagePage();
                          },
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('NaviCap'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('NaviCap')));
                    },
                  ),
                  ListTile(
                    title: const Text('Ayuda y soporte'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ayuda y soporte')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
