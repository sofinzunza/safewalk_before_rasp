import 'dart:developer' as developer;
import 'package:quick_actions/quick_actions.dart';

/// Servicio para integración con asistentes de voz (Siri y Google Assistant)
class VoiceAssistantService {
  final QuickActions _quickActions = const QuickActions();
  Function()? _onEmergencyActivated;

  /// Inicializar el servicio de asistente de voz
  ///
  /// Parámetros:
  /// - [onEmergencyActivated]: Callback que se ejecuta cuando se activa la emergencia por voz
  Future<void> initialize({required Function() onEmergencyActivated}) async {
    try {
      _onEmergencyActivated = onEmergencyActivated;

      // Configurar los shortcuts/acciones rápidas
      await _quickActions.setShortcutItems(<ShortcutItem>[
        const ShortcutItem(
          type: 'emergency_sos',
          localizedTitle: 'Activar SOS',
          icon: 'ic_emergency',
        ),
        const ShortcutItem(
          type: 'emergency_call',
          localizedTitle: 'Emergencia y Llamar',
          icon: 'ic_call_emergency',
        ),
        const ShortcutItem(
          type: 'emergency_location',
          localizedTitle: 'SOS con Ubicación',
          icon: 'ic_location_emergency',
        ),
      ]);

      // Escuchar cuando se activa un shortcut
      _quickActions.initialize((String shortcutType) {
        developer.log(
          '🎤 Atajo activado: $shortcutType',
          name: 'VoiceAssistantService',
        );

        // Ejecutar el callback de emergencia
        if (shortcutType.contains('emergency') &&
            _onEmergencyActivated != null) {
          developer.log(
            '🚨 Activando emergencia por comando de voz',
            name: 'VoiceAssistantService',
          );
          _onEmergencyActivated!();
        }
      });

      developer.log(
        '✅ Asistente de voz inicializado correctamente',
        name: 'VoiceAssistantService',
      );
    } catch (e) {
      developer.log(
        '❌ Error inicializando asistente de voz: $e',
        name: 'VoiceAssistantService',
      );
    }
  }

  /// Actualizar los shortcuts disponibles
  Future<void> updateShortcuts({
    bool includeCall = true,
    bool includeLocation = true,
  }) async {
    try {
      final shortcuts = <ShortcutItem>[
        const ShortcutItem(
          type: 'emergency_sos',
          localizedTitle: 'Activar SOS',
          icon: 'ic_emergency',
        ),
      ];

      if (includeCall) {
        shortcuts.add(
          const ShortcutItem(
            type: 'emergency_call',
            localizedTitle: 'Emergencia y Llamar',
            icon: 'ic_call_emergency',
          ),
        );
      }

      if (includeLocation) {
        shortcuts.add(
          const ShortcutItem(
            type: 'emergency_location',
            localizedTitle: 'SOS con Ubicación',
            icon: 'ic_location_emergency',
          ),
        );
      }

      await _quickActions.setShortcutItems(shortcuts);
      developer.log(
        '✅ Shortcuts actualizados (${shortcuts.length} disponibles)',
        name: 'VoiceAssistantService',
      );
    } catch (e) {
      developer.log(
        '❌ Error actualizando shortcuts: $e',
        name: 'VoiceAssistantService',
      );
    }
  }

  /// Limpiar shortcuts (útil al cerrar sesión)
  Future<void> clearShortcuts() async {
    try {
      await _quickActions.clearShortcutItems();
      developer.log('🧹 Shortcuts limpiados', name: 'VoiceAssistantService');
    } catch (e) {
      developer.log(
        '❌ Error limpiando shortcuts: $e',
        name: 'VoiceAssistantService',
      );
    }
  }
}

// Instancia global
final voiceAssistantService = VoiceAssistantService();
