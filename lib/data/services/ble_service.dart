import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/obstacle_data.dart';
import '../models/ble_config.dart';

/// Servicio principal para manejar conectividad BLE con SafeWalk NaviCap
class BleService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  // ---- UUIDs del protocolo SafeWalk ----
  static const String _serviceUuid = "12345678-1234-1234-1234-123456789abc";
  static const String _obstacleCharUuid =
      "87654321-4321-4321-4321-cba987654321";
  static const String _configCharUuid = "11111111-2222-3333-4444-555555555555";

  // ---- Estados de conexión ----
  static const int connectionStateDisconnected = 0;
  static const int connectionStateConnected = 1;
  static const int connectionStateSearching = 2;

  // ---- Estado interno ----
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _obstacleCharacteristic;
  BluetoothCharacteristic? _configCharacteristic;
  StreamSubscription? _obstacleSubscription;
  StreamSubscription? _connectionSubscription;
  Timer? _reconnectTimer;
  Timer? _scanTimer;

  // ---- Estado observable ----
  int _connectionState = connectionStateDisconnected;
  String _statusMessage = 'Desconectado';
  ObstacleData? _lastObstacleData;
  bool _isScanning = false;
  final List<BluetoothDevice> _safeWalkDevices = [];

  // ---- Getters ----
  int get connectionState => _connectionState;
  String get statusMessage => _statusMessage;
  ObstacleData? get lastObstacleData => _lastObstacleData;
  bool get isConnected => _connectionState == connectionStateConnected;
  bool get isScanning => _isScanning;
  List<BluetoothDevice> get safeWalkDevices =>
      List.unmodifiable(_safeWalkDevices);

  // ---- Streams para notificaciones ----
  final StreamController<ObstacleData> _obstacleStreamController =
      StreamController<ObstacleData>.broadcast();
  final StreamController<int> _connectionStateController =
      StreamController<int>.broadcast();

  Stream<ObstacleData> get obstacleDataStream =>
      _obstacleStreamController.stream;
  Stream<int> get connectionStateStream => _connectionStateController.stream;

  /// Inicializa el servicio BLE
  Future<void> initialize() async {
    developer.log('🔵 Inicializando BleService', name: 'BleService');
    await _configureTTS();

    // Verificar si Bluetooth está disponible
    if (await FlutterBluePlus.adapterState.first ==
        BluetoothAdapterState.unavailable) {
      _updateStatus(connectionStateDisconnected, 'Bluetooth no disponible');
      return;
    }

    // Solicitar permisos necesarios
    await _requestPermissions();

    // Configurar listeners de estado
    _setupBluetoothStateListener();

    // Verificar si Bluetooth está encendido
    final bluetoothState = await FlutterBluePlus.adapterState.first;
    if (bluetoothState == BluetoothAdapterState.on) {
      startAutoConnection();
    } else {
      _updateStatus(connectionStateDisconnected, 'Enciende el Bluetooth');
    }
  }

  /// Configura el TTS una sola vez al inicio
  Future<void> _configureTTS() async {
    try {
      await _tts.setLanguage("es-ES");
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      developer.log('🔊 TTS configurado', name: 'BleService');
    } catch (e) {
      developer.log("❌ Error configurando TTS: $e", name: "BleService");
    }
  }

  Future<void> _speak(String text) async {
    try {
      // ✅ Reconfigurar TTS antes de cada speak para asegurar consistency
      await _tts.setSpeechRate(0.5);
      await _tts.speak(text);
    } catch (e) {
      developer.log("🔇 Error al hablar: $e", name: "BleService");
    }
  }

  /// Solicita permisos BLE necesarios
  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    for (final permission in permissions) {
      if (await permission.isDenied) {
        await permission.request();
      }
    }
  }

  /// Configura el listener de estado de Bluetooth
  void _setupBluetoothStateListener() {
    FlutterBluePlus.adapterState.listen((state) {
      developer.log('📡 Estado Bluetooth: $state', name: 'BleService');

      if (state == BluetoothAdapterState.on) {
        if (!isConnected && !_isScanning) {
          startAutoConnection();
        }
      } else {
        _disconnect();
        _updateStatus(connectionStateDisconnected, 'Bluetooth desactivado');
      }
    });
  }

  /// Inicia conexión automática con dispositivos SafeWalk
  Future<void> startAutoConnection() async {
    if (_isScanning || isConnected) return;

    developer.log(
      '🔍 Iniciando búsqueda automática SafeWalk',
      name: 'BleService',
    );
    _updateStatus(connectionStateSearching, 'Buscando NaviCap...');

    final prefs = await SharedPreferences.getInstance();
    final savedDeviceId = prefs.getString('last_connected_device');

    // Intentar reconexión rápida si existe un dispositivo guardado
    if (savedDeviceId != null) {
      try {
        final device = BluetoothDevice(
          remoteId: DeviceIdentifier(savedDeviceId),
        );
        await device.connect(
          timeout: const Duration(seconds: 5),
          license: License.free,
        );
        _connectedDevice = device;

        _connectionSubscription = device.connectionState.listen((state) {
          if (state == BluetoothConnectionState.disconnected) {
            _onDeviceDisconnected();
          }
        });

        await _discoverServices(device);
        return;
      } catch (e) {
        developer.log('❌ Falló la reconexión rápida: $e', name: 'BleService');
      }
    }

    await _startScan();
  }

  /// Escanea dispositivos SafeWalk cercanos
  Future<void> _startScan() async {
    if (_isScanning) return;

    try {
      _isScanning = true;
      _safeWalkDevices.clear();
      notifyListeners();

      // Iniciar escaneo dirigido
      developer.log('🔎 Escaneando dispositivos BLE...', name: 'BleService');
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      // Configurar timer de timeout
      _scanTimer = Timer(const Duration(seconds: 10), () async {
        await _stopScan();
        if (_safeWalkDevices.isEmpty) {
          await _tts.stop();
          await Future.delayed(const Duration(milliseconds: 100));
          _speak("No se encontró ningún dispositivo");
          _updateStatus(connectionStateDisconnected, 'No se encontró NaviCap');
          _scheduleReconnect();
        }
      });

      // Escuchar resultados del escaneo
      FlutterBluePlus.scanResults.listen((results) async {
        for (final result in results) {
          final device = result.device;
          final deviceName = device.platformName;

          // Filtrar solo dispositivos SafeWalk/NaviCap
          if (_isSafeWalkDevice(deviceName) &&
              !_safeWalkDevices.contains(device)) {
            developer.log(
              '📱 Dispositivo SafeWalk encontrado: $deviceName',
              name: 'BleService',
            );
            _safeWalkDevices.add(device);
            notifyListeners();

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('last_connected_device', device.remoteId.str);

            // Conectar automáticamente al primer dispositivo encontrado
            await _connectToDevice(device);
            break;
          }
        }
      });
    } catch (e) {
      developer.log('❌ Error en escaneo: $e', name: 'BleService');
      _updateStatus(connectionStateDisconnected, 'Error en búsqueda');
      _scheduleReconnect();
    }
  }

  /// Verifica si el dispositivo es un SafeWalk/NaviCap
  bool _isSafeWalkDevice(String deviceName) {
    if (deviceName.isEmpty) return false;

    final normalizedName = deviceName.toLowerCase();
    return normalizedName.startsWith('safewalk') ||
        normalizedName.startsWith('navicap') ||
        normalizedName.contains('safewalk') ||
        normalizedName.contains('navicap');
  }

  /// Detiene el escaneo
  Future<void> _stopScan() async {
    if (!_isScanning) return;

    _isScanning = false;
    _scanTimer?.cancel();
    await FlutterBluePlus.stopScan();
    notifyListeners();
  }

  /// Conecta a un dispositivo específico
  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (isConnected) return;

    try {
      await _stopScan();
      _updateStatus(
        connectionStateSearching,
        'Conectando a ${device.platformName}...',
      );

      // Conectar al dispositivo
      await device.connect(
        timeout: const Duration(seconds: 10),
        license: License.free,
      );
      _connectedDevice = device;
      developer.log('✅ Conectado a ${device.platformName}', name: 'BleService');
      await _tts.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      await _speak("Dispositivo conectado");

      // Configurar listener de desconexión
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDeviceDisconnected();
        }
      });

      // Descubrir servicios
      await _discoverServices(device);
    } catch (e) {
      developer.log(
        '❌ Error conectando a ${device.platformName}: $e',
        name: 'BleService',
      );
      _updateStatus(connectionStateDisconnected, 'Error de conexión');
      _scheduleReconnect();
    }
  }

  /// Descubre y configura servicios BLE
  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();

      for (final service in services) {
        if (service.uuid.toString().toLowerCase() ==
            _serviceUuid.toLowerCase()) {
          developer.log('✅ Servicio SafeWalk encontrado', name: 'BleService');

          // Configurar características
          for (final characteristic in service.characteristics) {
            final uuid = characteristic.uuid.toString().toLowerCase();

            if (uuid == _obstacleCharUuid.toLowerCase()) {
              _obstacleCharacteristic = characteristic;
              await _setupObstacleNotifications();
            } else if (uuid == _configCharUuid.toLowerCase()) {
              _configCharacteristic = characteristic;
            }
          }

          if (_obstacleCharacteristic != null) {
            _updateStatus(connectionStateConnected, 'Conectado a NaviCap');
            await _sendCurrentConfiguration();
            developer.log(
              '🧢 NaviCap conectado exitosamente',
              name: 'BleService',
            );
            return;
          }
        }
      }

      // No se encontraron servicios SafeWalk
      await device.disconnect();
      _updateStatus(connectionStateDisconnected, 'Dispositivo incompatible');
      _scheduleReconnect();
    } catch (e) {
      developer.log('❌ Error descubriendo servicios: $e', name: 'BleService');
      await device.disconnect();
      _updateStatus(connectionStateDisconnected, 'Error de configuración');
      _scheduleReconnect();
    }
  }

  /// Configura notificaciones de obstáculos
  Future<void> _setupObstacleNotifications() async {
    if (_obstacleCharacteristic == null) return;

    try {
      // 1) Activar notificaciones en el GATT
      final ok = await _obstacleCharacteristic!.setNotifyValue(true);

      developer.log(
        '🔔 Notificaciones de obstáculos configuradas '
        '(setNotifyValue=$ok, isNotifying=${_obstacleCharacteristic!.isNotifying})',
        name: 'BleService',
      );

      // 2) Hacer un read() inicial para probar que la característica responde
      try {
        final initialValue = await _obstacleCharacteristic!.read();
        if (initialValue.isNotEmpty) {
          developer.log(
            '📥 Valor inicial de obstáculo (read): ${utf8.decode(initialValue)}',
            name: 'BleService',
          );
          _processObstacleData(initialValue);
        } else {
          developer.log(
            '📥 Valor inicial de obstáculo vacío (read)',
            name: 'BleService',
          );
        }
      } catch (e) {
        developer.log(
          '⚠️ Error en read() inicial de obstáculo: $e',
          name: 'BleService',
        );
      }

      // 3) Escuchar NOTIFICACIONES reales
      _obstacleSubscription = _obstacleCharacteristic!.onValueReceived.listen(
        (data) {
          developer.log(
            '📨 Notificación BLE recibida (bytes): $data',
            name: 'BleService',
          );
          _processObstacleData(data);
        },
        onError: (error) {
          developer.log(
            '❌ Error en notificaciones de obstáculos: $error',
            name: 'BleService',
          );
        },
        onDone: () {
          developer.log(
            'ℹ️ Stream de notificaciones de obstáculos cerrado',
            name: 'BleService',
          );
        },
      );

      developer.log(
        '✅ Listener de notificaciones de obstáculos SUSCRITO (onValueReceived)',
        name: 'BleService',
      );
    } catch (e) {
      developer.log(
        '❌ Error configurando notificaciones: $e',
        name: 'BleService',
      );
    }
  }

  /// Procesa datos de obstáculos recibidos desde BLE
  void _processObstacleData(List<int> data) {
    try {
      if (data.isEmpty) {
        developer.log(
          '⚠️ Datos vacíos recibidos desde BLE',
          name: 'BleService',
        );
        return;
      }
      final jsonString = utf8.decode(data).trim();
      final rawString = utf8.decode(data);
      final trimmed = rawString.trim();

      // Log SIEMPRE lo crudo que llega
      developer.log(
        '📦 RAW desde BLE (obstáculo): "$jsonString"',
        name: 'BleService',
      );
      if (jsonString.isEmpty) {
        developer.log('⚠️ JSON vacío después de trim()', name: 'BleService');
        return;
      }

      // Buscar el JSON entre llaves, por si viene con basura
      final start = trimmed.indexOf('{');
      final end = trimmed.lastIndexOf('}');

      if (start == -1 || end == -1 || end <= start) {
        developer.log(
          '⚠️ No se encontró JSON válido en: "$trimmed"',
          name: 'BleService',
        );
        return;
      }

      final cleanJson = trimmed.substring(start, end + 1);

      developer.log(
        '📦 JSON limpio para parsear: $cleanJson',
        name: 'BleService',
      );

      // Intentar parsear el JSON
      ObstacleData obstacleData;
      try {
        obstacleData = ObstacleData.fromJsonString(jsonString);
      } catch (e) {
        developer.log(
          '❌ Error haciendo jsonDecode / ObstacleData.fromJsonString: $e',
          name: 'BleService',
        );
        return;
      }

      _lastObstacleData = obstacleData;
      developer.log(
        '📍 Obstáculo recibido: ${obstacleData.obstacle} '
        'a ${obstacleData.distance}m, traffic: ${obstacleData.trafficLight}',
        name: 'BleService',
      );

      // Empujar al stream para ObstacleAlertService
      _obstacleStreamController.add(obstacleData);

      developer.log(
        '✅ Obstáculo agregado al stream, listeners: ${_obstacleStreamController.hasListener}',
        name: 'BleService',
      );

      notifyListeners();
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error procesando datos de obstáculo: $e\n$stackTrace',
        name: 'BleService',
      );
    }
  }

  /// Envía configuración actual a la Raspberry Pi
  Future<void> sendConfiguration(BleConfig config) async {
    if (_configCharacteristic == null || !isConnected) {
      developer.log(
        '⚠️ No se puede enviar configuración: sin conexión',
        name: 'BleService',
      );
      return;
    }

    try {
      final jsonData = config.toJsonString();
      final bytes = utf8.encode(jsonData);

      await _configCharacteristic!.write(bytes, withoutResponse: true);

      developer.log(
        '📤 Configuración enviada: ${config.toString()}',
        name: 'BleService',
      );
    } catch (e) {
      developer.log('❌ Error enviando configuración: $e', name: 'BleService');
    }
  }

  /// Envía configuración actual desde SharedPreferences
  Future<void> _sendCurrentConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsMap = <String, dynamic>{};

      // Recopilar todas las preferencias relevantes
      for (final key in prefs.getKeys()) {
        final value = prefs.get(key);
        if (value != null) {
          prefsMap[key] = value;
        }
      }

      final config = BleConfig.fromPreferences(prefsMap);
      await sendConfiguration(config);
    } catch (e) {
      developer.log(
        '❌ Error enviando configuración inicial: $e',
        name: 'BleService',
      );
    }
  }

  /// Maneja desconexión del dispositivo
  void _onDeviceDisconnected() {
    developer.log('📱 Dispositivo desconectado', name: 'BleService');
    _cleanup();
    _updateStatus(connectionStateDisconnected, 'Dispositivo desconectado');
    _scheduleReconnect();
  }

  /// Programa reconexión automática
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!isConnected) {
        developer.log('🔄 Intentando reconectar...', name: 'BleService');
        _speakWithDelay("Intentando reconectar");
        startAutoConnection();
      }
    });
  }

  /// Desconecta manualmente
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    await _disconnect();
    _updateStatus(connectionStateDisconnected, 'Desconectado manualmente');
  }

  /// Desconecta del dispositivo actual
  Future<void> _disconnect() async {
    await _stopScan();

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        developer.log('❌ Error desconectando: $e', name: 'BleService');
      }
    }

    _cleanup();
  }

  /// Limpia recursos y suscripciones
  void _cleanup() {
    _obstacleSubscription?.cancel();
    _connectionSubscription?.cancel();
    _obstacleSubscription = null;
    _connectionSubscription = null;
    _connectedDevice = null;
    _obstacleCharacteristic = null;
    _configCharacteristic = null;
  }

  /// Actualiza estado y notifica listeners
  void _updateStatus(int state, String message) {
    _connectionState = state;
    _statusMessage = message;
    _connectionStateController.add(state);
    notifyListeners();

    developer.log('📊 Estado: $message ($state)', name: 'BleService');

    // ✅ Detener TTS actual y hablar con una pequeña pausa
    _speakWithDelay(message);
  }

  /// Habla el mensaje con una pequeña pausa para asegurar configuración correcta
  Future<void> _speakWithDelay(String message) async {
    try {
      await _tts.stop();
      // Pequeña pausa para que el TTS procese el stop
      await Future.delayed(const Duration(milliseconds: 100));
      await _speak(message);
    } catch (e) {
      developer.log("🔇 Error en _speakWithDelay: $e", name: "BleService");
    }
  }

  /// Obtiene estado de conexión para MultiStateButton
  int getConnectionStateForUI() {
    return _connectionState;
  }

  /// Cicla entre estados de conexión (para botón manual)
  Future<void> toggleConnection() async {
    switch (_connectionState) {
      case connectionStateDisconnected:
        await startAutoConnection();
        break;
      case connectionStateConnected:
        await disconnect();
        break;
      case connectionStateSearching:
        await _stopScan();
        _updateStatus(connectionStateDisconnected, 'Búsqueda cancelada');
        break;
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _scanTimer?.cancel();
    _disconnect();
    _obstacleStreamController.close();
    _connectionStateController.close();
    super.dispose();
  }
}
