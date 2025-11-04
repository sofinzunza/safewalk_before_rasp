import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/notifiers.dart';
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

  /// Lista de todas las claves de alertas de obstáculos específicos
  /// (EXCLUYENDO alertas de semáforo peatonal)
  static const List<String> _obstacleAlertKeys = [
    'alert_people',
    'alert_stairs',
    'alert_cars',
    'alert_motorcycles',
    'alert_bikes',
    'alert_dogs',
    'alert_tree',
    'alert_door',
    'alert_escalator',
  ];

  /// Claves para guardar el estado previo de las alertas
  static const String _backupPrefix = 'backup_';

  /// Guarda el estado actual de las alertas de obstáculos antes de desactivarlas
  static Future<void> _saveObstacleAlertsBackup() async {
    final prefs = await SharedPreferences.getInstance();

    for (final key in _obstacleAlertKeys) {
      final currentValue = prefs.getBool(key) ?? false;
      await prefs.setBool('$_backupPrefix$key', currentValue);
    }

    developer.log(
      '💾 Estado de alertas guardado como backup',
      name: 'AlertUtils',
    );
  }

  /// Desactiva todas las alertas de obstáculos específicos
  /// (mantiene el estado de alertas de semáforo peatonal)
  static Future<void> disableAllObstacleAlerts() async {
    // ✅ NUEVO: Guardar estado actual antes de desactivar
    await _saveObstacleAlertsBackup();

    final prefs = await SharedPreferences.getInstance();

    for (final key in _obstacleAlertKeys) {
      await prefs.setBool(key, false);
    }

    await notifyConfigurationChanged();
    developer.log(
      '🚫 Todas las alertas de obstáculos desactivadas',
      name: 'AlertUtils',
    );
  }

  /// Reactiva las alertas de obstáculos restaurando el estado previo del usuario
  /// o establece valores por defecto si es la primera vez
  static Future<void> enableObstacleAlerts() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ NUEVO: Intentar restaurar desde backup primero
    bool restoredFromBackup = false;

    for (final key in _obstacleAlertKeys) {
      final backupKey = '$_backupPrefix$key';
      if (prefs.containsKey(backupKey)) {
        final backupValue = prefs.getBool(backupKey) ?? false;
        await prefs.setBool(key, backupValue);
        restoredFromBackup = true;
      }
    }

    // Si no hay backup, usar valores por defecto
    if (!restoredFromBackup) {
      const defaultValues = {
        'alert_people': true,
        'alert_stairs': false,
        'alert_cars': true,
        'alert_motorcycles': false,
        'alert_bikes': false,
        'alert_dogs': true,
        'alert_tree': false,
        'alert_door': true,
        'alert_escalator': false,
      };

      for (final entry in defaultValues.entries) {
        if (!prefs.containsKey(entry.key)) {
          await prefs.setBool(entry.key, entry.value);
        }
      }

      developer.log(
        '🔧 Alertas activadas con valores por defecto',
        name: 'AlertUtils',
      );
    } else {
      developer.log(
        '✅ Alertas restauradas desde configuración previa',
        name: 'AlertUtils',
      );
    }

    await notifyConfigurationChanged();
  }

  /// Verifica si hay alguna alerta de obstáculo activada
  static Future<bool> hasAnyObstacleAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    for (final key in _obstacleAlertKeys) {
      if (prefs.getBool(key) ?? false) {
        return true;
      }
    }

    return false;
  }

  // ✅ NUEVO: Métodos para el switch "atajo" de home_page (solo cambia valores, no UI)

  /// Desactiva todas las alertas de obstáculos desde home_page (sin deshabilitar UI)
  /// Solo cambia los valores, alerts_page mantiene control visual
  static Future<void> setAllObstacleAlertsFromHome(bool enabled) async {
    if (enabled) {
      // Si se activa, restaurar desde backup o usar defaults
      await enableObstacleAlerts();
    } else {
      // Si se desactiva, solo cambiar valores (sin backup)
      await _disableObstacleAlertsQuiet();
    }

    developer.log(
      '🏠 Switch home_page cambió alertas de obstáculos: $enabled',
      name: 'AlertUtils',
    );
  }

  /// Desactiva alertas sin guardar backup (para cambios desde home_page)
  static Future<void> _disableObstacleAlertsQuiet() async {
    final prefs = await SharedPreferences.getInstance();

    for (final key in _obstacleAlertKeys) {
      await prefs.setBool(key, false);
    }

    await notifyConfigurationChanged();
    developer.log(
      '🔕 Alertas de obstáculos desactivadas (modo silencioso)',
      name: 'AlertUtils',
    );
  }

  /// Limpia los backups de alertas de obstáculos (opcional, para mantenimiento)
  static Future<void> clearObstacleAlertsBackup() async {
    final prefs = await SharedPreferences.getInstance();

    for (final key in _obstacleAlertKeys) {
      final backupKey = '$_backupPrefix$key';
      await prefs.remove(backupKey);
    }

    developer.log('🗑️ Backup de alertas limpiado', name: 'AlertUtils');
  }

  /// Verifica si existe un backup de alertas de obstáculos
  static Future<bool> hasObstacleAlertsBackup() async {
    final prefs = await SharedPreferences.getInstance();

    for (final key in _obstacleAlertKeys) {
      final backupKey = '$_backupPrefix$key';
      if (prefs.containsKey(backupKey)) {
        return true;
      }
    }

    return false;
  }

  // ✅ NUEVO: Manejo de sincronización de alertas de semáforo peatonal

  /// Claves para las alertas de semáforo peatonal (ambas deben estar sincronizadas)
  static const String _homePageCrosswalkKey = 'estado_semaforo';
  static const String _alertsPageCrosswalkKey = 'alert_crosswalk_state';

  /// Sincroniza el estado de las alertas de semáforo entre ambas páginas
  static Future<void> setCrosswalkAlertState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar en ambas claves para mantener sincronización
    await prefs.setBool(_homePageCrosswalkKey, enabled);
    await prefs.setBool(_alertsPageCrosswalkKey, enabled);

    // Notificar el cambio
    crosswalkAlertsNotifier.value = enabled;

    await notifyConfigurationChanged();
    developer.log(
      '🚦 Estado semáforo sincronizado: $enabled',
      name: 'AlertUtils',
    );
  }

  /// Obtiene el estado actual de las alertas de semáforo
  static Future<bool> getCrosswalkAlertState() async {
    final prefs = await SharedPreferences.getInstance();

    // Priorizar la clave de alerts_page, con fallback a home_page
    final alertsPageValue = prefs.getBool(_alertsPageCrosswalkKey);
    final homePageValue = prefs.getBool(_homePageCrosswalkKey);

    // Si hay inconsistencias, usar el valor de alerts_page y sincronizar
    bool finalValue = alertsPageValue ?? homePageValue ?? true;

    // Sincronizar si hay diferencias
    if (alertsPageValue != homePageValue) {
      await setCrosswalkAlertState(finalValue);
    }

    return finalValue;
  }

  /// Inicializa el notifier de semáforo con el valor guardado
  static Future<void> initializeCrosswalkNotifier() async {
    final currentState = await getCrosswalkAlertState();
    crosswalkAlertsNotifier.value = currentState;
  }
}
