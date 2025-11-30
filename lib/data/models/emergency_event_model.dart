// lib/data/models/emergency_event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum EmergencyStatus { active, resolved, cancelled }

class EmergencyEventModel {
  final String id;
  final String userId; // UID del usuario con discapacidad visual
  final double lat;
  final double lng;
  final String? address;
  final EmergencyStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<String> notifiedContactIds; // Contactos que fueron notificados

  EmergencyEventModel({
    required this.id,
    required this.userId,
    required this.lat,
    required this.lng,
    this.address,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.notifiedContactIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'lat': lat,
      'lng': lng,
      'address': address,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'notifiedContactIds': notifiedContactIds,
    };
  }

  factory EmergencyEventModel.fromMap(Map<String, dynamic> map, String docId) {
    return EmergencyEventModel(
      id: docId,
      userId: map['userId'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      lng: map['lng']?.toDouble() ?? 0.0,
      address: map['address'],
      status: EmergencyStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EmergencyStatus.active,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      resolvedAt: map['resolvedAt'] != null
          ? (map['resolvedAt'] as Timestamp).toDate()
          : null,
      notifiedContactIds: List<String>.from(map['notifiedContactIds'] ?? []),
    );
  }
}
