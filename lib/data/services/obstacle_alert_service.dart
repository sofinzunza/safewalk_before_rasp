import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/obstacle_data.dart';
import '../models/ble_config.dart';
import 'ble_service.dart';
import 'wake_lock_service.dart';

/// Servicio para manejar alertas de obstáculos con TTS y vibración
class ObstacleAlertService extends ChangeNotifier {
  // ---- Instancias de servicios ----
  final BleService _bleService;
  final FlutterTts _tts = FlutterTts();

  // ---- Configuración de alertas ----
  BleConfig? _currentConfig;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  // ---- Suscripciones ----
  StreamSubscription<ObstacleData>? _obstacleSubscription;

  // ---- Control de frecuencia de alertas ----
  DateTime? _lastAlertTime;
  String? _lastObstacleType;
  static const Duration _minAlertInterval = Duration(seconds: 2);

  ObstacleAlertService(this._bleService);

  /// Inicializa el servicio de alertas
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configurar TTS
    await _setupTts();

    // Cargar configuración
    await _loadConfiguration();

    // Suscribirse a datos de obstáculos
    _setupObstacleListener();

    // ✅ Activar wake lock para recibir alertas con pantalla bloqueada
    await WakeLockService.enable();

    _isInitialized = true;
    developer.log(
      '✅ ObstacleAlertService inicializado con wake lock activo',
      name: 'ObstacleAlertService',
    );
  }

  /// Configura el motor de texto a voz
  Future<void> _setupTts() async {
    try {
      // Configuración básica de TTS
      await _tts.setLanguage("es-ES"); // Español de España
      await _tts.setSpeechRate(
        0.8,
      ); // Velocidad normal-lenta para accesibilidad
      await _tts.setPitch(1.0);

      // Configurar callbacks
      _tts.setStartHandler(() {
        _isSpeaking = true;
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        developer.log('❌ Error TTS: $msg', name: 'ObstacleAlertService');
      });

      // Probar disponibilidad de idioma
      final languages = await _tts.getLanguages;
      if (languages.contains("es-ES")) {
        await _tts.setLanguage("es-ES");
      } else if (languages.contains("es-MX")) {
        await _tts.setLanguage("es-MX");
      } else if (languages.contains("es-US")) {
        await _tts.setLanguage("es-US");
      }

      developer.log(
        '✅ TTS configurado correctamente',
        name: 'ObstacleAlertService',
      );
    } catch (e) {
      developer.log(
        '❌ Error configurando TTS: $e',
        name: 'ObstacleAlertService',
      );
    }
  }

  /// Carga configuración desde SharedPreferences
  Future<void> _loadConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsMap = <String, dynamic>{};

      for (final key in prefs.getKeys()) {
        final value = prefs.get(key);
        if (value != null) {
          prefsMap[key] = value;
        }
      }

      _currentConfig = BleConfig.fromPreferences(prefsMap);
      await _updateTtsFromConfig();

      developer.log(
        '⚙️ Configuración cargada: ${_currentConfig.toString()}',
        name: 'ObstacleAlertService',
      );
    } catch (e) {
      developer.log(
        '❌ Error cargando configuración: $e',
        name: 'ObstacleAlertService',
      );
      // Configuración por defecto
      _currentConfig = const BleConfig(
        vibration: false,
        vibrationIntensity: 50,
        sound: true,
        volumeIntensity: 50,
        alertPeople: true,
        alertStairs: false,
        alertCars: true,
        alertMotorcycles: false,
        alertBikes: false,
        alertDogs: true,
        alertTree: false,
        alertDoor: false,
        alertEscalator: false,
        alertCrosswalkState: true,
      );
    }
  }

  /// Actualiza configuración de TTS según config actual
  Future<void> _updateTtsFromConfig() async {
    if (_currentConfig == null) return;

    try {
      // Configurar volumen basado en intensidad
      final volume = _currentConfig!.volumeIntensity / 100.0;
      await _tts.setVolume(volume);

      developer.log(
        '🔊 Volumen TTS configurado: ${(volume * 100).round()}%',
        name: 'ObstacleAlertService',
      );
    } catch (e) {
      developer.log(
        '❌ Error configurando TTS: $e',
        name: 'ObstacleAlertService',
      );
    }
  }

  /// Configura listener para datos de obstáculos
  void _setupObstacleListener() {
    developer.log(
      '👂 Configurando listener de obstáculos...',
      name: 'ObstacleAlertService',
    );

    _obstacleSubscription = _bleService.obstacleDataStream.listen(
      (obstacleData) {
        developer.log(
          '📨 Stream recibió: ${obstacleData.obstacle}',
          name: 'ObstacleAlertService',
        );
        _processObstacleAlert(obstacleData);
      },
      onError: (error) {
        developer.log(
          '❌ Error en stream de obstáculos: $error',
          name: 'ObstacleAlertService',
        );
      },
      onDone: () {
        developer.log(
          '✅ Stream de obstáculos cerrado',
          name: 'ObstacleAlertService',
        );
      },
    );

    developer.log(
      '✅ Listener configurado, suscrito: ${_obstacleSubscription != null}',
      name: 'ObstacleAlertService',
    );
  }

  /// Procesa y ejecuta alertas de obstáculos
  Future<void> _processObstacleAlert(ObstacleData obstacleData) async {
    developer.log(
      '🔔 RECIBIDO: ${obstacleData.obstacle} a ${obstacleData.distance}m, traffic: ${obstacleData.trafficLight}',
      name: 'ObstacleAlertService',
    );

    if (_currentConfig == null) {
      developer.log('⚠️ Config es null', name: 'ObstacleAlertService');
      return;
    }

    developer.log(
      '⚙️ Config actual - sound: ${_currentConfig!.sound}, vibration: ${_currentConfig!.vibration}, minDist: ${_currentConfig!.minDistance}, maxDist: ${_currentConfig!.maxDistance}',
      name: 'ObstacleAlertService',
    );

    // ✅ NUEVO: Procesar alertas de semáforo independientemente
    if (obstacleData.trafficLight != null &&
        obstacleData.trafficLight != 'unknown') {
      developer.log(
        '🚦 Procesando semáforo: ${obstacleData.trafficLight}',
        name: 'ObstacleAlertService',
      );
      await _processTrafficLightAlert(obstacleData);
    }

    // Si el obstáculo es 'none' o 'ready', no alertar
    if (obstacleData.obstacle == 'none' || obstacleData.obstacle == 'ready') {
      developer.log(
        '⏭️ Obstáculo ignorado: ${obstacleData.obstacle}',
        name: 'ObstacleAlertService',
      );
      return;
    }

    // Verificar si el obstáculo está habilitado
    final isEnabled = _currentConfig!.isObstacleEnabled(obstacleData.obstacle);
    developer.log(
      '🔍 Obstáculo "${obstacleData.obstacle}" habilitado: $isEnabled',
      name: 'ObstacleAlertService',
    );

    if (!isEnabled) {
      developer.log(
        '⏭️ Obstáculo deshabilitado: ${obstacleData.obstacle}',
        name: 'ObstacleAlertService',
      );
      return;
    }

    // Verificar rango de distancia
    final inRange = _currentConfig!.isDistanceInRange(obstacleData.distance);
    developer.log(
      '📏 Distancia ${obstacleData.distance}m en rango [${_currentConfig!.minDistance}-${_currentConfig!.maxDistance}]: $inRange',
      name: 'ObstacleAlertService',
    );

    if (!inRange) {
      developer.log(
        '📏 Obstáculo fuera de rango: ${obstacleData.distance}m',
        name: 'ObstacleAlertService',
      );
      return;
    }

    // Control de frecuencia de alertas
    if (_shouldThrottleAlert(obstacleData)) {
      developer.log('⏱️ Alerta throttled', name: 'ObstacleAlertService');
      return;
    }

    developer.log(
      '🚨 EJECUTANDO ALERTA: ${obstacleData.obstacle} a ${obstacleData.distance}m',
      name: 'ObstacleAlertService',
    );

    // Ejecutar alertas según configuración
    final alertTasks = <Future>[];

    // Alerta de vibración
    if (_currentConfig!.vibration) {
      developer.log('📳 Agregando vibración', name: 'ObstacleAlertService');
      alertTasks.add(_triggerVibration(obstacleData));
    }

    // Alerta de sonido/voz
    if (_currentConfig!.sound) {
      developer.log('🔊 Agregando TTS', name: 'ObstacleAlertService');
      alertTasks.add(_triggerVoiceAlert(obstacleData));
    }

    // Ejecutar alertas en paralelo
    await Future.wait(alertTasks);

    // Actualizar tiempo de última alerta
    _lastAlertTime = DateTime.now();
    _lastObstacleType = obstacleData.obstacle;

    notifyListeners();
  }

  /// ✅ NUEVO: Procesar alertas de semáforo
  Future<void> _processTrafficLightAlert(ObstacleData obstacleData) async {
    // Verificar si las alertas de semáforo están habilitadas
    if (!_currentConfig!.alertCrosswalkState) {
      return;
    }

    // Solo alertar si hay un obstáculo cerca Y el semáforo está en rojo
    if (obstacleData.trafficLight == 'red') {
      developer.log(
        '🚦 Semáforo en rojo detectado',
        name: 'ObstacleAlertService',
      );

      // Alerta de voz para semáforo
      if (_currentConfig!.sound && !_isSpeaking) {
        await _tts.speak('Semáforo en rojo, no cruces');
        HapticFeedback.mediumImpact();
      }

      // Vibración para semáforo
      if (_currentConfig!.vibration) {
        await Vibration.vibrate(pattern: [0, 200, 100, 200]);
      }
    } else if (obstacleData.trafficLight == 'green') {
      developer.log(
        '🚦 Semáforo en verde detectado',
        name: 'ObstacleAlertService',
      );

      // Solo informar si está configurado para dar info positiva
      if (_currentConfig!.sound && !_isSpeaking) {
        await _tts.speak('Semáforo en verde, puedes cruzar');
        HapticFeedback.lightImpact();
      }
    }
  }

  /// Determina si se debe limitar la frecuencia de alertas
  bool _shouldThrottleAlert(ObstacleData obstacleData) {
    if (_lastAlertTime == null) return false;

    final now = DateTime.now();
    final timeSinceLastAlert = now.difference(_lastAlertTime!);

    // Si es el mismo tipo de obstáculo y no ha pasado suficiente tiempo
    if (_lastObstacleType == obstacleData.obstacle &&
        timeSinceLastAlert < _minAlertInterval) {
      return true;
    }

    return false;
  }

  /// Ejecuta alerta de vibración
  Future<void> _triggerVibration(ObstacleData obstacleData) async {
    try {
      // Verificar si el dispositivo soporta vibración
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != true) {
        developer.log(
          '📱 Dispositivo sin vibración',
          name: 'ObstacleAlertService',
        );
        return;
      }

      // Calcular patrón de vibración según prioridad
      final priority = obstacleData.getPriority();

      // Mapear intensidad del slider (0-100) a amplitud real (128-255)
      // Mínimo 128 (50% de 255) para que sea perceptible, máximo 255 (100%)
      final sliderValue = _currentConfig!.vibrationIntensity;
      final intensity = (128 + (sliderValue / 100.0 * 127)).round().clamp(
        128,
        255,
      );

      List<int> pattern;
      List<int> intensities;

      switch (priority) {
        case AlertPriority.critical:
          // 4 pulsos muy largos e intensos con pausas cortas
          pattern = [0, 800, 150, 800, 150, 800, 150, 800];
          intensities = [intensity, 0, intensity, 0, intensity, 0, intensity];
          break;
        case AlertPriority.high:
          // 3 pulsos largos con pausas cortas
          pattern = [0, 600, 150, 600, 150, 600];
          intensities = [intensity, 0, intensity, 0, intensity];
          break;
        case AlertPriority.medium:
          // 2 pulsos medianos
          pattern = [0, 400, 100, 400];
          intensities = [intensity, 0, intensity];
          break;
        case AlertPriority.low:
          // 1 pulso corto
          pattern = [0, 250];
          intensities = [intensity];
          break;
      }

      // Ejecutar vibración
      if (await Vibration.hasAmplitudeControl()) {
        await Vibration.vibrate(pattern: pattern, intensities: intensities);
      } else {
        await Vibration.vibrate(pattern: pattern);
      }

      developer.log(
        '📳 Vibración ejecutada: ${priority.name}',
        name: 'ObstacleAlertService',
      );
    } catch (e) {
      developer.log('❌ Error en vibración: $e', name: 'ObstacleAlertService');
    }
  }

  /// Ejecuta alerta de voz
  Future<void> _triggerVoiceAlert(ObstacleData obstacleData) async {
    try {
      // No interrumpir si ya está hablando
      if (_isSpeaking) {
        developer.log(
          '🗣️ TTS ocupado, saltando alerta',
          name: 'ObstacleAlertService',
        );
        return;
      }

      // Obtener mensaje de alerta accesible
      final message = obstacleData.getAlertMessage();

      // Ejecutar TTS
      await _tts.speak(message);

      developer.log(
        '🗣️ Alerta de voz: $message',
        name: 'ObstacleAlertService',
      );

      // Feedback háptico ligero
      HapticFeedback.lightImpact();
    } catch (e) {
      developer.log(
        '❌ Error en alerta de voz: $e',
        name: 'ObstacleAlertService',
      );
    }
  }

  /// Actualiza configuración de alertas
  Future<void> updateConfiguration(BleConfig newConfig) async {
    _currentConfig = newConfig;
    await _updateTtsFromConfig();

    // Enviar nueva configuración a la Raspberry Pi
    await _bleService.sendConfiguration(newConfig);

    developer.log('⚙️ Configuración actualizada', name: 'ObstacleAlertService');
    notifyListeners();
  }

  /// Recarga configuración desde SharedPreferences
  Future<void> reloadConfiguration() async {
    await _loadConfiguration();
    notifyListeners();
  }

  /// Detiene TTS si está hablando
  Future<void> stopCurrentAlert() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
    }
  }

  /// Prueba alerta con datos de ejemplo
  Future<void> testAlert() async {
    final testData = ObstacleData(
      obstacle: 'person',
      distance: 2.0,
      confidence: 0.95,
      timestamp: DateTime.now(),
    );

    await _processObstacleAlert(testData);
  }

  /// Obtiene configuración actual
  BleConfig? get currentConfig => _currentConfig;

  /// Verifica si TTS está activo
  bool get isSpeaking => _isSpeaking;

  @override
  void dispose() {
    _obstacleSubscription?.cancel();
    _tts.stop();

    // ✅ Desactivar wake lock al cerrar el servicio
    WakeLockService.disable();

    super.dispose();
  }
}
