import 'package:safewalk/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertUtils {
  /// Determina el estado de alerta basado en las preferencias de vibración y sonido
  /// 0 = Ambos, 1 = Solo sonido, 2 = Solo vibración, 3 = Desactivadas
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

  /// Actualiza las preferencias de vibración y sonido basado en el estado de alerta
  static Future<void> setAlertState(int alertState) async {
    final prefs = await SharedPreferences.getInstance();

    switch (alertState) {
      case 0: // Ambos
        await prefs.setBool(KContanse.vibrationKey, true);
        await prefs.setBool(KContanse.soundKey, true);
        break;
      case 1: // Solo sonido
        await prefs.setBool(KContanse.vibrationKey, false);
        await prefs.setBool(KContanse.soundKey, true);
        break;
      case 2: // Solo vibración
        await prefs.setBool(KContanse.vibrationKey, true);
        await prefs.setBool(KContanse.soundKey, false);
        break;
      case 3: // Desactivadas
        await prefs.setBool(KContanse.vibrationKey, false);
        await prefs.setBool(KContanse.soundKey, false);
        break;
    }
  }
}
