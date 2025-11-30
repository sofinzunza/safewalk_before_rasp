import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/models/emergency_event_model.dart';
import 'package:safewalk/data/services/firestore_service.dart';
import 'package:safewalk/data/services/location_service.dart';
import 'package:geocoding/geocoding.dart';
import 'signal_painter.dart';

class SosButtom extends StatefulWidget {
  const SosButtom({super.key});

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

  @override
  void dispose() {
    _ctrl.dispose();
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

        // Obtener ubicación actual
        final position = await locationService.getCurrentLocation();
        if (position == null) {
          throw Exception('No se pudo obtener la ubicación');
        }

        // Obtener dirección (opcional)
        String? address;
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final parts = <String>[];
            if ((p.street ?? '').isNotEmpty) parts.add(p.street!);
            if ((p.locality ?? '').isNotEmpty) parts.add(p.locality!);
            address = parts.join(', ');
          }
        } catch (_) {}

        // Obtener contactos de emergencia
        final contacts = await firestoreService.getEmergencyContacts(
          currentUserId,
        );

        if (contacts.isEmpty) {
          throw Exception('No tienes contactos de emergencia configurados');
        }

        // Crear evento de emergencia
        final event = EmergencyEventModel(
          id: '', // Se asignará automáticamente
          userId: currentUserId,
          lat: position.latitude,
          lng: position.longitude,
          address: address,
          status: EmergencyStatus.active,
          createdAt: DateTime.now(),
          notifiedContactIds: contacts.map((c) => c.uid).toList(),
        );

        final eventId = await firestoreService.createEmergencyEvent(event);
        setState(() => _currentEmergencyId = eventId);

        // Activar compartir ubicación en tiempo real
        await locationService.startSharingLocation(currentUserId);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Emergencia activada - ${contacts.length} contacto(s) notificado(s)',
            ),
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

      if (_currentEmergencyId != null) {
        await firestoreService.updateEmergencyStatus(
          eventId: _currentEmergencyId!,
          status: EmergencyStatus.cancelled,
        );
      }

      await locationService.stopSharingLocation();

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

    return Semantics(
      button: true,
      hint:
          'Presiona para activar la emergencia, presiona de nuevo para cancelar',
      onTapHint: 'Iniciando llamada de emergencia',
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) => CustomPaint(
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
                  : Colors.red[400],
              elevation: 10,
            ),
            child: _isSendingEmergency
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 110,
                  ),
          ),
        ],
      ),
    );
  }
}
