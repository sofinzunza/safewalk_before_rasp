import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/notifiers.dart';
import 'package:safewalk/data/alert_utils.dart';
import 'package:safewalk/data/language_notifier.dart';
import 'package:safewalk/data/services/notification_service.dart';
import 'package:safewalk/data/services/voice_assistant_service.dart';
import 'package:safewalk/views/pages/start_page.dart';
import 'package:safewalk/views/auth_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Clave global para navegación desde comandos de voz
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AlertUtils.initializeCrosswalkNotifier();
  await LanguageService.loadSavedLanguage();

  // Inicializar servicio de notificaciones
  await notificationService.initialize();

  // Inicializar servicio de asistente de voz (Siri/Google Assistant)
  await voiceAssistantService.initialize(
    onEmergencyActivated: () {
      // Navegar a la página de emergencia cuando se active por voz
      navigatorKey.currentState?.pushNamed('/emergency');
    },
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    initThemeMode();
    super.initState();
  }

  void initThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? repeat = prefs.getBool(KContanse.themeModeKey);
    isDarkModeNotifier.value = repeat ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return ValueListenableBuilder(
          valueListenable: localeNotifier,
          builder: (context, locale, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              locale: locale,
              theme: ThemeData(
                fontFamily: 'DMSans',
                colorScheme: ColorScheme.fromSeed(
                  seedColor: KColors.tealChillon,
                  brightness: isDarkMode ? Brightness.dark : Brightness.light,
                ),
              ),
              home: const AuthLayout(pageIfNotConnected: StartPage()),
            );
          },
        );
      },
    );
  }
}
