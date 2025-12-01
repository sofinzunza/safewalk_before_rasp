import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/models/emergency_event_model.dart';
import 'package:safewalk/data/services/firestore_service.dart';
import 'package:safewalk/data/services/location_service.dart';
import 'package:safewalk/data/services/notification_service.dart';
import 'package:geocoding/geocoding.dart';
import 'signal_painter.dart';

class SosButtom extends StatefulWidget {
  const SosButtom({
    super.key,
    this.shouldSendLocation = true,
    this.shouldCallEmergency = true,
  });

  final bool shouldSendLocation;
  final bool shouldCallEmergency;

  @override
  State<SosButtom> createState() => _SosButtomState();
}

class _SosButtomState extends State<SosButtom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final Animation<double> _pulse = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );

  bool _pressed = false;
  bool _isSendingEmergency = false;
  String? _currentEmergencyId;

  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  Future<void> _setupTts() async {
    try {
      await _tts.setLanguage("es-ES");
      await _tts.setSpeechRate(0.8);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
    } catch (e) {
      debugPrint('Error configurando TTS: $e');
    }
  }

  Future<void> _speak(String message) async {
    try {
      await _tts.speak(message);
    } catch (e) {
      debugPrint('Error en TTS: $e');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _onPressed() async {
    if (_isSendingEmergency) return;

    if (!_pressed) {
      // Activar emergencia
      setState(() {
        _pressed = true;
        _isSendingEmergency = true;
      });

      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) {
          throw Exception('Usuario no autenticado');
        }

        // Anunciar activación de emergencia
        await _speak('Alerta S O S activada');

        // Obtener ubicación actual solo si está habilitado
        double? latitude;
        double? longitude;
        String? address;

        if (widget.shouldSendLocation) {
          await _speak('Enviando ubicación');

          final position = await locationService.getCurrentLocation();
          if (position == null) {
            throw Exception('No se pudo obtener la ubicación');
          }

          latitude = position.latitude;
          longitude = position.longitude;

          // Obtener dirección (opcional)
          try {
            final placemarks = await placemarkFromCoordinates(
              latitude,
              longitude,
            );
            if (placemarks.isNotEmpty) {
              final p = placemarks.first;
              final parts = <String>[];
              if ((p.street ?? '').isNotEmpty) parts.add(p.street!);
              if ((p.locality ?? '').isNotEmpty) parts.add(p.locality!);
              address = parts.join(', ');
            }
          } catch (e) {
            debugPrint('Error obteniendo dirección: $e');
          }
        }

        // Obtener contactos de emergencia
        final contacts = await firestoreService.getEmergencyContacts(
          currentUserId,
        );

        if (contacts.isEmpty) {
          throw Exception('No tienes contactos de emergencia configurados');
        }

        // Anunciar llamada si está habilitada
        if (widget.shouldCallEmergency) {
          await _speak('Llamando a contacto de emergencia');
        }

        // Crear evento de emergencia
        final event = EmergencyEventModel(
          id: '', // Se asignará automáticamente
          userId: currentUserId,
          lat: latitude ?? 0.0, // Valor por defecto si no hay ubicación
          lng: longitude ?? 0.0, // Valor por defecto si no hay ubicación
          address: address,
          status: EmergencyStatus.active,
          createdAt: DateTime.now(),
          notifiedContactIds: contacts.map((c) => c.uid).toList(),
        );

        final eventId = await firestoreService.createEmergencyEvent(event);
        setState(() => _currentEmergencyId = eventId);

        // Obtener perfil del usuario para el nombre
        final userProfile = await firestoreService.getUserProfile(
          currentUserId,
        );
        final userName = userProfile?.name ?? 'Un usuario';

        // Enviar notificaciones a los contactos de emergencia
        await firestoreService.notifyEmergencyContacts(
          userId: currentUserId,
          userName: userName,
          lat: latitude,
          lng: longitude,
        );

        // Mostrar notificación local de emergencia
        await notificationService.showEmergencyNotification(
          userName: userName,
          userId: currentUserId,
        );

        // Activar compartir ubicación en tiempo real solo si está habilitado
        if (widget.shouldSendLocation) {
          await locationService.startSharingLocation(currentUserId);
        }

        if (!mounted) return;

        String statusMessage =
            'Emergencia activada - ${contacts.length} contacto(s) notificado(s)';
        if (widget.shouldSendLocation && widget.shouldCallEmergency) {
          statusMessage += '\nUbicación y llamada activadas';
        } else if (widget.shouldSendLocation) {
          statusMessage += '\nUbicación activada';
        } else if (widget.shouldCallEmergency) {
          statusMessage += '\nLlamada activada';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusMessage),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[800],
            duration: const Duration(seconds: 4),
          ),
        );
        setState(() => _pressed = false);
      } finally {
        setState(() => _isSendingEmergency = false);
      }
    } else {
      // Cancelar emergencia
      setState(() => _pressed = false);

      await _speak('Emergencia cancelada');

      if (_currentEmergencyId != null) {
        await firestoreService.updateEmergencyStatus(
          eventId: _currentEmergencyId!,
          status: EmergencyStatus.cancelled,
        );
      }

      // Detener ubicación en tiempo real solo si estaba activa
      if (widget.shouldSendLocation) {
        await locationService.stopSharingLocation();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergencia cancelada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const size = 260.0;
    final String statusLabel = _pressed
        ? 'Emergencia activada. Presiona para cancelar'
        : 'Botón de emergencia. Presiona para activar';

    return Semantics(
      button: true,
      label: statusLabel,
      hint: _pressed
          ? 'Doble toque para cancelar la emergencia'
          : 'Doble toque para activar emergencia y notificar a tus contactos',
      enabled: !_isSendingEmergency,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) => CustomPaint(
              painter: SignalPainter(
                progress: _pulse.value,
                color: KColors.naranjo,
              ),
              child: const SizedBox(width: size, height: size),
            ),
          ),
          ElevatedButton(
            onPressed: _isSendingEmergency ? null : _onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(50),
              backgroundColor: _isSendingEmergency
                  ? Colors.grey
                  : (_pressed ? Colors.red[700] : Colors.red[400]),
              elevation: 10,
            ),
            child: _isSendingEmergency
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    semanticsLabel: 'Activando emergencia',
                  )
                : Icon(
                    _pressed
                        ? Icons.cancel_outlined
                        : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 110,
                    semanticLabel: _pressed ? 'Cancelar' : 'SOS',
                  ),
          ),
        ],
      ),
    );
  }
}
