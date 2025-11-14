import 'dart:convert';

/// Modelo para los datos de obstáculos enviados desde la Raspberry Pi
class ObstacleData {
  final String obstacle; // "door", "person", etc.
  final double distance; // metros
  final String? trafficLight; // "red", "green", "unknown"
  final DateTime timestamp; // ts de la Pi
  final double? confidence; // opcional (puede venir null)

  ObstacleData({
    required this.obstacle,
    required this.distance,
    required this.timestamp,
    this.trafficLight,
    this.confidence,
  });

  /// Crea ObstacleData desde un Map JSON
  factory ObstacleData.fromJson(Map<String, dynamic> json) {
    return ObstacleData(
      obstacle: (json['obstacle'] ?? 'unknown').toString(),
      distance: (json['distance'] as num? ?? 0).toDouble(),
      // La Pi manda "traffic", pero dejamos compatibilidad con "traffic_light"
      trafficLight:
          json['traffic'] as String? ?? json['traffic_light'] as String?,
      timestamp: _parseTimestamp(json['ts'] ?? json['timestamp']),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  /// Crea ObstacleData desde el String JSON recibido vía BLE
  factory ObstacleData.fromJsonString(String jsonString) {
    final Map<String, dynamic> map =
        json.decode(jsonString) as Map<String, dynamic>;
    return ObstacleData.fromJson(map);
  }

  /// Helper para parsear timestamp flexible
  static DateTime _parseTimestamp(dynamic ts) {
    if (ts == null) return DateTime.now();

    if (ts is String && ts.isNotEmpty) {
      try {
        return DateTime.parse(ts); // soporta "2025-11-13T06:18:53Z"
      } catch (_) {
        return DateTime.now();
      }
    }

    if (ts is num) {
      // Epoch en segundos
      return DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000);
    }

    return DateTime.now();
  }

  /// Convierte a JSON (útil para logs/debug)
  Map<String, dynamic> toJson() {
    return {
      'obstacle': obstacle,
      'distance': distance,
      'traffic': trafficLight,
      'ts': timestamp.toUtc().toIso8601String(),
      if (confidence != null) 'confidence': confidence,
    };
  }

  String getObstacleIcon() {
    switch (obstacle.toLowerCase()) {
      case 'person':
      case 'people':
        return '👤';
      case 'car':
      case 'auto':
        return '🚗';
      case 'motorcycle':
      case 'moto':
        return '🏍️';
      case 'bicycle':
      case 'bike':
      case 'bicicleta':
        return '🚲';
      case 'dog':
      case 'perro':
        return '🐕';
      case 'tree':
      case 'árbol':
        return '🌳';
      case 'stairs':
      case 'escalera':
        return '🪜';
      case 'door':
      case 'puerta':
        return '🚪';
      case 'escalator':
      case 'escalera mecánica':
        return '🚇';
      case 'traffic_light':
      case 'semáforo':
        return '🚦';
      default:
        return '⚠️';
    }
  }

  /// Mensaje de alerta en español para TTS
  String getAlertMessage() {
    final distanceText = distance < 1.0
        ? '${(distance * 100).round()} centímetros'
        : '${distance.toStringAsFixed(1)} metros';

    String baseMessage;
    switch (obstacle.toLowerCase()) {
      case 'person':
      case 'people':
        baseMessage = 'Persona detectada a $distanceText';
        break;
      case 'car':
      case 'auto':
        baseMessage = 'Auto detectado a $distanceText';
        break;
      case 'motorcycle':
      case 'moto':
        baseMessage = 'Motocicleta detectada a $distanceText';
        break;
      case 'bicycle':
      case 'bike':
      case 'bicicleta':
        baseMessage = 'Bicicleta detectada a $distanceText';
        break;
      case 'dog':
      case 'perro':
        baseMessage = 'Perro detectado a $distanceText';
        break;
      case 'tree':
      case 'árbol':
        baseMessage = 'Árbol detectado a $distanceText';
        break;
      case 'stairs':
      case 'escalera':
        baseMessage = 'Escaleras detectadas a $distanceText';
        break;
      case 'door':
      case 'puerta':
        baseMessage = 'Puerta detectada a $distanceText';
        break;
      case 'escalator':
      case 'escalera mecánica':
        baseMessage = 'Escalera mecánica detectada a $distanceText';
        break;
      default:
        baseMessage = 'Obstáculo detectado a $distanceText';
    }

    // Info de semáforo si existe y no es "unknown"
    if (trafficLight != null && trafficLight != 'unknown') {
      final trafficMessage = trafficLight == 'green'
          ? 'Semáforo en verde, puedes cruzar'
          : 'Semáforo en rojo, no cruces';
      baseMessage += '. $trafficMessage';
    }

    return baseMessage;
  }

  /// Determina si el obstáculo requiere alerta urgente
  bool isUrgent() {
    final c = confidence ?? 1.0; // si no hay confianza, asumimos alta
    return distance < 1.5 && c > 0.7;
  }

  /// Determina el nivel de prioridad de la alerta
  AlertPriority getPriority() {
    final c = confidence ?? 1.0;
    if (distance < 1.0 && c > 0.8) {
      return AlertPriority.critical;
    } else if (distance < 2.0 && c > 0.6) {
      return AlertPriority.high;
    } else if (distance < 3.0) {
      return AlertPriority.medium;
    } else {
      return AlertPriority.low;
    }
  }

  @override
  String toString() {
    final confPercent = confidence != null ? (confidence! * 100).round() : null;
    final confText = confPercent != null ? '$confPercent%' : 'n/a';
    return 'ObstacleData(obstacle: $obstacle, distance: ${distance.toStringAsFixed(2)}m, confidence: $confText, trafficLight: $trafficLight)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ObstacleData &&
        other.obstacle == obstacle &&
        other.distance == distance &&
        other.confidence == confidence &&
        other.trafficLight == trafficLight &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(obstacle, distance, confidence, trafficLight, timestamp);
  }
}

/// Enum para niveles de prioridad de alertas
enum AlertPriority { low, medium, high, critical }

extension AlertPriorityExtension on AlertPriority {
  String get name {
    switch (this) {
      case AlertPriority.low:
        return 'Baja';
      case AlertPriority.medium:
        return 'Media';
      case AlertPriority.high:
        return 'Alta';
      case AlertPriority.critical:
        return 'Crítica';
    }
  }

  Duration get vibrationDuration {
    switch (this) {
      case AlertPriority.low:
        return const Duration(milliseconds: 200);
      case AlertPriority.medium:
        return const Duration(milliseconds: 400);
      case AlertPriority.high:
        return const Duration(milliseconds: 600);
      case AlertPriority.critical:
        return const Duration(milliseconds: 1000);
    }
  }

  int get vibrationIntensity {
    switch (this) {
      case AlertPriority.low:
        return 1;
      case AlertPriority.medium:
        return 3;
      case AlertPriority.high:
        return 5;
      case AlertPriority.critical:
        return 10;
    }
  }
}
