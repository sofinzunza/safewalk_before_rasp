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
      // Verificar si los servicios de ubicación están habilitados
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log(
          '⚠️ Servicios de ubicación desactivados',
          name: 'LocationService',
        );
        return false;
      }

      // Verificar y solicitar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      developer.log('Permiso actual: $permission', name: 'LocationService');

      if (permission == LocationPermission.denied) {
        developer.log(
          'Solicitando permisos de ubicación...',
          name: 'LocationService',
        );
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log(
            '❌ Permiso de ubicación denegado',
            name: 'LocationService',
          );
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log(
          '❌ Permiso de ubicación denegado permanentemente',
          name: 'LocationService',
        );
        return false;
      }

      developer.log(
        '✅ Permisos otorgados, obteniendo ubicación...',
        name: 'LocationService',
      );

      // Obtener ubicación inicial con timeout
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );

        developer.log(
          '📍 Ubicación obtenida: ${position.latitude}, ${position.longitude}',
          name: 'LocationService',
        );

        await firestoreService.updateUserLocation(
          uid: userId,
          lat: position.latitude,
          lng: position.longitude,
        );
      } catch (e) {
        developer.log(
          '⚠️ Error obteniendo ubicación inicial: $e',
          name: 'LocationService',
        );
        // Continuar de todos modos, el stream puede funcionar
      }

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
          ).listen(
            (Position position) {
              developer.log(
                '📍 Ubicación actualizada: ${position.latitude}, ${position.longitude}',
                name: 'LocationService',
              );
              firestoreService.updateUserLocation(
                uid: userId,
                lat: position.latitude,
                lng: position.longitude,
              );
            },
            onError: (error) {
              developer.log(
                '❌ Error en stream de ubicación: $error',
                name: 'LocationService',
              );
            },
          );

      _currentUserId = userId;
      _isSharing = true;
      developer.log('✅ Compartir ubicación iniciado', name: 'LocationService');
      return true;
    } catch (e) {
      developer.log(
        '❌ Error al iniciar compartir ubicación: $e',
        name: 'LocationService',
      );
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
      // Verificar servicios
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log(
          '⚠️ Servicios de ubicación desactivados',
          name: 'LocationService',
        );
        return null;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      developer.log('Permiso actual: $permission', name: 'LocationService');

      if (permission == LocationPermission.denied) {
        developer.log(
          'Solicitando permisos de ubicación...',
          name: 'LocationService',
        );
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log(
            '❌ Permiso de ubicación denegado',
            name: 'LocationService',
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log(
          '❌ Permiso de ubicación denegado permanentemente',
          name: 'LocationService',
        );
        return null;
      }

      developer.log(
        '✅ Permisos otorgados, obteniendo ubicación...',
        name: 'LocationService',
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      developer.log(
        '✅ Ubicación obtenida: ${position.latitude}, ${position.longitude}',
        name: 'LocationService',
      );

      return position;
    } catch (e) {
      developer.log(
        '❌ Error al obtener ubicación: $e',
        name: 'LocationService',
      );
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
