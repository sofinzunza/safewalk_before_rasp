// lib/data/services/firestore_service.dart
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safewalk/data/models/user_model.dart';
import 'package:safewalk/data/models/emergency_event_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== USUARIOS ==========

  /// Crear perfil de usuario en Firestore
  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  /// Obtener perfil de usuario
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      developer.log('Error al obtener perfil: $e');
      return null;
    }
  }

  /// Actualizar perfil de usuario
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(uid).update(updates);
  }

  /// Stream de perfil de usuario (escucha cambios en tiempo real)
  Stream<UserModel?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  // ========== CONTACTOS DE EMERGENCIA ==========

  /// Buscar usuario por email
  Future<UserModel?> findUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return UserModel.fromMap(query.docs.first.data());
    } catch (e) {
      developer.log('Error al buscar usuario: $e');
      return null;
    }
  }

  /// Buscar usuario por teléfono
  Future<UserModel?> findUserByPhone(String phone) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return UserModel.fromMap(query.docs.first.data());
    } catch (e) {
      developer.log('Error al buscar usuario por teléfono: $e');
      return null;
    }
  }

  /// Agregar contacto de emergencia (para usuario con discapacidad visual)
  Future<bool> addEmergencyContact({
    required String visuallyImpairedUid,
    required String emergencyContactUid,
  }) async {
    try {
      // Verificar que el contacto sea tipo emergencyContact
      final contactProfile = await getUserProfile(emergencyContactUid);
      if (contactProfile?.userType != UserType.emergencyContact) {
        developer.log('El usuario no es un contacto de emergencia válido');
        return false;
      }

      // Agregar en ambas direcciones
      await _firestore.collection('users').doc(visuallyImpairedUid).update({
        'emergencyContactIds': FieldValue.arrayUnion([emergencyContactUid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(emergencyContactUid).update({
        'linkedVisuallyImpairedIds': FieldValue.arrayUnion([
          visuallyImpairedUid,
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      developer.log('Error al agregar contacto: $e');
      return false;
    }
  }

  /// Eliminar contacto de emergencia
  Future<bool> removeEmergencyContact({
    required String visuallyImpairedUid,
    required String emergencyContactUid,
  }) async {
    try {
      await _firestore.collection('users').doc(visuallyImpairedUid).update({
        'emergencyContactIds': FieldValue.arrayRemove([emergencyContactUid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(emergencyContactUid).update({
        'linkedVisuallyImpairedIds': FieldValue.arrayRemove([
          visuallyImpairedUid,
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      developer.log('Error al eliminar contacto: $e');
      return false;
    }
  }

  /// Obtener lista de contactos de emergencia
  Future<List<UserModel>> getEmergencyContacts(
    String visuallyImpairedUid,
  ) async {
    try {
      final user = await getUserProfile(visuallyImpairedUid);
      if (user == null || user.emergencyContactIds.isEmpty) return [];

      final List<UserModel> contacts = [];
      for (final contactId in user.emergencyContactIds) {
        final contact = await getUserProfile(contactId);
        if (contact != null) contacts.add(contact);
      }
      return contacts;
    } catch (e) {
      developer.log('Error al obtener contactos: $e');
      return [];
    }
  }

  /// Obtener lista de personas con discapacidad visual vinculadas (para tutores)
  Future<List<UserModel>> getLinkedVisuallyImpaired(
    String emergencyContactUid,
  ) async {
    try {
      final user = await getUserProfile(emergencyContactUid);
      if (user == null || user.linkedVisuallyImpairedIds.isEmpty) return [];

      final List<UserModel> linkedUsers = [];
      for (final userId in user.linkedVisuallyImpairedIds) {
        final linkedUser = await getUserProfile(userId);
        if (linkedUser != null) linkedUsers.add(linkedUser);
      }
      return linkedUsers;
    } catch (e) {
      developer.log('Error al obtener usuarios vinculados: $e');
      return [];
    }
  }

  // ========== UBICACIÓN EN TIEMPO REAL ==========

  /// Actualizar ubicación del usuario
  Future<void> updateUserLocation({
    required String uid,
    required double lat,
    required double lng,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'currentLat': lat,
      'currentLng': lng,
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    });
  }

  /// Activar/desactivar compartir ubicación
  Future<void> toggleLocationSharing(String uid, bool isActive) async {
    await _firestore.collection('users').doc(uid).update({
      'isLocationSharingActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream de ubicación de un usuario específico
  Stream<Map<String, dynamic>?> watchUserLocation(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return {
        'lat': data['currentLat'],
        'lng': data['currentLng'],
        'lastUpdate': data['lastLocationUpdate'],
        'isActive': data['isLocationSharingActive'] ?? false,
      };
    });
  }

  // ========== EVENTOS DE EMERGENCIA ==========

  /// Crear evento de emergencia
  Future<String> createEmergencyEvent(EmergencyEventModel event) async {
    final docRef = await _firestore
        .collection('emergency_events')
        .add(event.toMap());
    return docRef.id;
  }

  /// Actualizar estado de emergencia
  Future<void> updateEmergencyStatus({
    required String eventId,
    required EmergencyStatus status,
  }) async {
    final updates = {
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == EmergencyStatus.resolved ||
        status == EmergencyStatus.cancelled) {
      updates['resolvedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('emergency_events')
        .doc(eventId)
        .update(updates);
  }

  /// Obtener eventos de emergencia activos de un usuario
  Stream<List<EmergencyEventModel>> watchActiveEmergencies(String userId) {
    return _firestore
        .collection('emergency_events')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EmergencyEventModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Obtener historial de emergencias
  Future<List<EmergencyEventModel>> getEmergencyHistory(String userId) async {
    try {
      final query = await _firestore
          .collection('emergency_events')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return query.docs
          .map((doc) => EmergencyEventModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      developer.log('Error al obtener historial: $e');
      return [];
    }
  }
}

// Instancia global
final firestoreService = FirestoreService();
