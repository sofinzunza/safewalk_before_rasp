import 'dart:convert';

/// Modelo para los datos de obstáculos enviados desde la Raspberry Pi
class ObstacleData {
  final String obstacle;
  final double distance;
  final double confidence;
  final String? trafficLight; // 'red', 'green', o null
  final DateTime timestamp;

  const ObstacleData({
    required this.obstacle,
    required this.distance,
    required this.confidence,
    this.trafficLight,
    required this.timestamp,
  });

  /// Factory constructor para crear desde JSON recibido vía BLE
  factory ObstacleData.fromJson(Map<String, dynamic> json) {
    return ObstacleData(
      obstacle: json['obstacle'] as String,
      distance: (json['distance'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      trafficLight: json['traffic_light'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as num).toInt() * 1000,
      ),
    );
  }

  /// Convierte a JSON para logging o debugging
  Map<String, dynamic> toJson() {
    return {
      'obstacle': obstacle,
      'distance': distance,
      'confidence': confidence,
      'traffic_light': trafficLight,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Convierte desde String JSON recibido vía BLE
  factory ObstacleData.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ObstacleData.fromJson(json);
  }

  /// Obtiene el icono apropiado según el tipo de obstáculo
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
      case 'dog':
      case 'perro':
        return '🐕';
      case 'tree':
      case 'árbol':
        return '🌳';
      case 'stairs':
      case 'escalera':
        return '🪜';
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

  /// Obtiene el mensaje de alerta en español para VoiceOver/TalkBack
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
      case 'escalator':
      case 'escalera mecánica':
        baseMessage = 'Escalera mecánica detectada a $distanceText';
        break;
      default:
        baseMessage = 'Obstáculo detectado a $distanceText';
    }

    // Agregar información del semáforo si está disponible
    if (trafficLight != null) {
      final trafficMessage = trafficLight == 'green' 
          ? 'Semáforo en verde, puedes pasar'
          : 'Semáforo en rojo, no pases';
      baseMessage += '. $trafficMessage';
    }

    return baseMessage;
  }

  /// Determina si el obstáculo requiere alerta urgente
  bool isUrgent() {
    return distance < 1.5 && confidence > 0.7;
  }

  /// Determina el nivel de prioridad de la alerta
  AlertPriority getPriority() {
    if (distance < 1.0 && confidence > 0.8) {
      return AlertPriority.critical;
    } else if (distance < 2.0 && confidence > 0.6) {
      return AlertPriority.high;
    } else if (distance < 3.0) {
      return AlertPriority.medium;
    } else {
      return AlertPriority.low;
    }
  }

  @override
  String toString() {
    return 'ObstacleData(obstacle: $obstacle, distance: ${distance}m, confidence: ${(confidence * 100).round()}%, trafficLight: $trafficLight)';
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
    return Object.hash(
      obstacle,
      distance,
      confidence,
      trafficLight,
      timestamp,
    );
  }
}

/// Enum para niveles de prioridad de alertas
enum AlertPriority {
  low,
  medium,
  high,
  critical,
}

/// Extensión para obtener información de prioridad
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

  /// Duración de vibración según prioridad
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

  /// Intensidad de vibración según prioridad
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