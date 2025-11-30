// lib/data/services/location_service.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import 'package:safewalk/data/services/firestore_service.dart';

class LocationService {
  StreamSubscription<Position>? _locationSubscription;
  String? _currentUserId;
  bool _isSharing = false;

  bool get isSharing => _isSharing;

  /// Iniciar compartir ubicación en tiempo real
  Future<bool> startSharingLocation(String userId) async {
    try {
      // Verificar permisos
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('Servicios de ubicación desactivados');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log('Permiso de ubicación denegado');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log('Permiso de ubicación denegado permanentemente');
        return false;
      }

      // Obtener ubicación inicial
      final position = await Geolocator.getCurrentPosition();
      await firestoreService.updateUserLocation(
        uid: userId,
        lat: position.latitude,
        lng: position.longitude,
      );

      // Activar flag en Firestore
      await firestoreService.toggleLocationSharing(userId, true);

      // Iniciar stream de ubicación
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Actualizar cada 10 metros
      );

      _locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen((Position position) {
            firestoreService.updateUserLocation(
              uid: userId,
              lat: position.latitude,
              lng: position.longitude,
            );
          });

      _currentUserId = userId;
      _isSharing = true;
      return true;
    } catch (e) {
      developer.log('Error al iniciar compartir ubicación: $e');
      return false;
    }
  }

  /// Detener compartir ubicación
  Future<void> stopSharingLocation() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    if (_currentUserId != null) {
      await firestoreService.toggleLocationSharing(_currentUserId!, false);
    }

    _isSharing = false;
    _currentUserId = null;
  }

  /// Obtener ubicación actual una sola vez
  Future<Position?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      developer.log('Error al obtener ubicación: $e');
      return null;
    }
  }

  /// Limpiar recursos
  void dispose() {
    _locationSubscription?.cancel();
  }
}

// Instancia global
final locationService = LocationService();
