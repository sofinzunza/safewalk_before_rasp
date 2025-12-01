import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safewalk/data/notifiers.dart';
import 'package:safewalk/data/services/firestore_service.dart';
import 'package:safewalk/views/pages/tlocation_page.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Manejador de mensajes en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log(
    '📨 Mensaje en segundo plano: ${message.messageId}',
    name: 'NotificationService',
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  /// Inicializar servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Solicitar permisos
      await _requestPermissions();

      // Configurar notificaciones locales
      await _setupLocalNotifications();

      // Configurar Firebase Messaging
      await _setupFirebaseMessaging();

      // Obtener y guardar FCM token
      await _getFcmToken();

      _isInitialized = true;
      developer.log(
        '✅ NotificationService inicializado',
        name: 'NotificationService',
      );
    } catch (e) {
      developer.log(
        '❌ Error inicializando NotificationService: $e',
        name: 'NotificationService',
      );
    }
  }

  /// Solicitar permisos de notificaciones
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    developer.log(
      '🔔 Permisos de notificación: ${settings.authorizationStatus}',
      name: 'NotificationService',
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      developer.log(
        '✅ Permisos de notificación concedidos',
        name: 'NotificationService',
      );
    } else {
      developer.log(
        '⚠️ Permisos de notificación no concedidos',
        name: 'NotificationService',
      );
    }
  }

  /// Configurar notificaciones locales
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Canal de notificaciones para Android (alta prioridad para emergencias)
    const androidChannel = AndroidNotificationChannel(
      'emergency_channel',
      'Emergencias',
      description: 'Notificaciones de alertas SOS',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    developer.log(
      '✅ Notificaciones locales configuradas',
      name: 'NotificationService',
    );
  }

  /// Configurar Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    // Configurar handler para mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Manejar cuando se toca una notificación y la app se abre
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar si la app fue abierta desde una notificación
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    developer.log(
      '✅ Firebase Messaging configurado',
      name: 'NotificationService',
    );
  }

  /// Obtener y guardar FCM token
  Future<void> _getFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _fcmToken = token;
        developer.log('🔑 FCM Token: $token', name: 'NotificationService');

        // Guardar token en Firestore
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await firestoreService.updateUserProfile(currentUser.uid, {
            'fcmToken': token,
          });
        }
      }

      // Escuchar cambios en el token
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        developer.log(
          '🔄 FCM Token actualizado: $newToken',
          name: 'NotificationService',
        );

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await firestoreService.updateUserProfile(currentUser.uid, {
            'fcmToken': newToken,
          });
        }
      });
    } catch (e) {
      developer.log(
        '❌ Error obteniendo FCM token: $e',
        name: 'NotificationService',
      );
    }
  }

  /// Manejar mensaje en primer plano
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    developer.log(
      '📬 Mensaje en primer plano: ${message.notification?.title}',
      name: 'NotificationService',
    );

    // Mostrar notificación local
    await _showLocalNotification(message);
  }

  /// Manejar cuando se abre la app desde una notificación
  void _handleMessageOpenedApp(RemoteMessage message) {
    developer.log(
      '📲 App abierta desde notificación: ${message.data}',
      name: 'NotificationService',
    );

    // Aquí puedes navegar a una pantalla específica
    // Por ejemplo, si es una emergencia, navegar al mapa
    if (message.data['type'] == 'emergency_alert') {
      developer.log('🚨 Abrir mapa de emergencia', name: 'NotificationService');

      final double? lat =
          double.tryParse(message.data['lat']?.toString() ?? '');
      final double? lng =
          double.tryParse(message.data['lng']?.toString() ?? '');
      final String? userId = message.data['userId']?.toString();

      void navigateToLiveLocation() {
        final navigator = appNavigatorKey.currentState;
        if (navigator == null) return;

        navigator.push(
          MaterialPageRoute(
            builder: (_) => TlocationPage(
              lat: lat,
              lng: lng,
              userId: userId,
            ),
          ),
        );
      }

      if (appNavigatorKey.currentState == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigateToLiveLocation();
        });
      } else {
        navigateToLiveLocation();
      }
    }
  }

  /// Manejar cuando se toca una notificación local
  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      '👆 Notificación tocada: ${response.payload}',
      name: 'NotificationService',
    );

    // Aquí puedes manejar la navegación según el payload
    if (response.payload != null && response.payload!.contains('emergency')) {
      selectedPageNotifier.value = 2;
      developer.log(
        '🚨 Abrir pantalla de emergencia',
        name: 'NotificationService',
      );
    }
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'emergency_channel',
      'Emergencias',
      channelDescription: 'Notificaciones de alertas SOS',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      ticker: notification.title,
      icon: android?.smallIcon ?? '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Enviar notificación de emergencia a un contacto
  /// Nota: Esto debe ser llamado desde el backend (Cloud Functions)
  /// Este método solo prepara los datos para enviar
  Map<String, dynamic> buildEmergencyNotificationData({
    required String userName,
    required String userId,
    required double? lat,
    required double? lng,
  }) {
    return {
      'type': 'emergency_alert',
      'title': '🚨 ALERTA SOS',
      'body': '¡$userName necesita ayuda! Ve la ubicación en tiempo real',
      'userId': userId,
      'lat': lat?.toString() ?? '0',
      'lng': lng?.toString() ?? '0',
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }

  /// Mostrar notificación de emergencia local (para testing)
  Future<void> showEmergencyNotification({
    required String userName,
    required String userId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'emergency_channel',
      'Emergencias',
      channelDescription: 'Notificaciones de alertas SOS',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      ticker: 'ALERTA SOS',
      styleInformation: BigTextStyleInformation(
        '¡$userName necesita ayuda! Ve la ubicación en tiempo real',
        htmlFormatBigText: true,
        contentTitle: '🚨 ALERTA SOS',
        htmlFormatContentTitle: true,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
      sound: 'default',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🚨 ALERTA SOS',
      '¡$userName necesita ayuda! Ve la ubicación en tiempo real',
      details,
      payload: 'emergency:$userId',
    );
  }

  String? get fcmToken => _fcmToken;
}

final notificationService = NotificationService();
