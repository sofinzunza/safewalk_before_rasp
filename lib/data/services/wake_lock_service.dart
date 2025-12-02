import 'dart:developer' as developer;
import 'package:wakelock_plus/wakelock_plus.dart';

/// Servicio para mantener la app activa durante alertas de obstáculos
/// Permite recibir notificaciones con vibración incluso con pantalla bloqueada
class WakeLockService {
  static bool _isEnabled = false;

  /// Activa el wake lock para mantener la app activa
  /// Esto permite que las alertas de obstáculos funcionen con pantalla bloqueada
  static Future<void> enable() async {
    try {
      if (!_isEnabled) {
        await WakelockPlus.enable();
        _isEnabled = true;
        developer.log(
          '🔓 Wake lock activado - App se mantendrá activa en segundo plano',
          name: 'WakeLockService',
        );
      }
    } catch (e) {
      developer.log('❌ Error activando wake lock: $e', name: 'WakeLockService');
    }
  }

  /// Desactiva el wake lock para ahorrar batería
  static Future<void> disable() async {
    try {
      if (_isEnabled) {
        await WakelockPlus.disable();
        _isEnabled = false;
        developer.log(
          '🔒 Wake lock desactivado - App puede entrar en suspensión',
          name: 'WakeLockService',
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error desactivando wake lock: $e',
        name: 'WakeLockService',
      );
    }
  }

  /// Verifica si el wake lock está activo
  static Future<bool> isEnabled() async {
    try {
      return await WakelockPlus.enabled;
    } catch (e) {
      developer.log(
        '❌ Error verificando wake lock: $e',
        name: 'WakeLockService',
      );
      return false;
    }
  }

  /// Alterna el estado del wake lock
  static Future<void> toggle() async {
    if (_isEnabled) {
      await disable();
    } else {
      await enable();
    }
  }
}
