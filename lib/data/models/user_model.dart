// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { visuallyImpaired, emergencyContact }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? rut;
  final String? phone;
  final UserType userType;
  final List<String> emergencyContactIds; // UIDs de contactos de emergencia
  final List<String>
  linkedVisuallyImpairedIds; // UIDs de personas con discapacidad visual vinculadas
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Para compartir ubicación en tiempo real
  final double? currentLat;
  final double? currentLng;
  final DateTime? lastLocationUpdate;
  final bool isLocationSharingActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.rut,
    this.phone,
    required this.userType,
    this.emergencyContactIds = const [],
    this.linkedVisuallyImpairedIds = const [],
    required this.createdAt,
    this.updatedAt,
    this.currentLat,
    this.currentLng,
    this.lastLocationUpdate,
    this.isLocationSharingActive = false,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'rut': rut,
      'phone': phone,
      'userType': userType == UserType.visuallyImpaired
          ? 'visuallyImpaired'
          : 'emergencyContact',
      'emergencyContactIds': emergencyContactIds,
      'linkedVisuallyImpairedIds': linkedVisuallyImpairedIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'lastLocationUpdate': lastLocationUpdate != null
          ? Timestamp.fromDate(lastLocationUpdate!)
          : null,
      'isLocationSharingActive': isLocationSharingActive,
    };
  }

  // Crear desde Map de Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      rut: map['rut'],
      phone: map['phone'],
      userType: map['userType'] == 'visuallyImpaired'
          ? UserType.visuallyImpaired
          : UserType.emergencyContact,
      emergencyContactIds: List<String>.from(map['emergencyContactIds'] ?? []),
      linkedVisuallyImpairedIds: List<String>.from(
        map['linkedVisuallyImpairedIds'] ?? [],
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      currentLat: map['currentLat']?.toDouble(),
      currentLng: map['currentLng']?.toDouble(),
      lastLocationUpdate: map['lastLocationUpdate'] != null
          ? (map['lastLocationUpdate'] as Timestamp).toDate()
          : null,
      isLocationSharingActive: map['isLocationSharingActive'] ?? false,
    );
  }

  // Crear copia con cambios
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? rut,
    String? phone,
    UserType? userType,
    List<String>? emergencyContactIds,
    List<String>? linkedVisuallyImpairedIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? currentLat,
    double? currentLng,
    DateTime? lastLocationUpdate,
    bool? isLocationSharingActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      rut: rut ?? this.rut,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      emergencyContactIds: emergencyContactIds ?? this.emergencyContactIds,
      linkedVisuallyImpairedIds:
          linkedVisuallyImpairedIds ?? this.linkedVisuallyImpairedIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      isLocationSharingActive:
          isLocationSharingActive ?? this.isLocationSharingActive,
    );
  }
}
