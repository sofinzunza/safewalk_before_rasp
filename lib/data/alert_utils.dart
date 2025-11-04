import 'package:safewalk/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class AlertUtils {
  /// Obtiene el estado actual de las alertas basado en las preferencias
  /// Estados: 0=ambos, 1=solo sonido, 2=solo vibración, 3=desactivadas
  static Future<int> getAlertState() async {
    final prefs = await SharedPreferences.getInstance();

    final vibration = prefs.getBool(KContanse.vibrationKey) ?? false;
    final sound = prefs.getBool(KContanse.soundKey) ?? true;

    if (vibration && sound) {
      return 0; // Ambos
    } else if (!vibration && sound) {
      return 1; // Solo sonido
    } else if (vibration && !sound) {
      return 2; // Solo vibración
    } else {
      return 3; // Desactivadas
    }
  }

  /// Establece el estado de las alertas y actualiza SharedPreferences
  static Future<void> setAlertState(int state) async {
    final prefs = await SharedPreferences.getInstance();

    bool vibration;
    bool sound;

    switch (state) {
      case 0: // Ambos
        vibration = true;
        sound = true;
        break;
      case 1: // Solo sonido
        vibration = false;
        sound = true;
        break;
      case 2: // Solo vibración
        vibration = true;
        sound = false;
        break;
      case 3: // Desactivadas
        vibration = false;
        sound = false;
        break;
      default:
        vibration = false;
        sound = true;
    }

    await prefs.setBool(KContanse.vibrationKey, vibration);
    await prefs.setBool(KContanse.soundKey, sound);
  }

  static Future<void> notifyConfigurationChanged() async {
    developer.log(
      '📤 Configuración actualizada y sincronizada',
      name: 'AlertUtils',
    );
  }

  static Future<Map<String, dynamic>> getAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> prefsMap = {};

    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value != null) {
        prefsMap[key] = value;
      }
    }

    return prefsMap;
  }
}
