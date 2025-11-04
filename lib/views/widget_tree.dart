import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/notifiers.dart';
import 'package:safewalk/views/pages/alerts_page.dart';
import 'package:safewalk/views/pages/emergency_page.dart';
import 'package:safewalk/views/pages/home_page.dart';
import 'package:safewalk/views/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/navbar_widget.dart';

List<Widget> pages = [
  HomePage(),
  AlertsPage(),
  EmergencyPage(),
  SettingsPage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ValueListenableBuilder(
            valueListenable: isDarkModeNotifier,
            builder: (context, isDarkMode, child) {
              return IconButton(
                onPressed: () async {
                  isDarkModeNotifier.value = !isDarkModeNotifier.value;
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool(
                    KContanse.themeModeKey,
                    isDarkModeNotifier.value,
                  );
                },
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
