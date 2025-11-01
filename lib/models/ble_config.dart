import 'dart:convert';

/// Modelo para la configuración BLE que se envía a la Raspberry Pi
class BleConfig {
  // Configuraciones de alertas (basadas en alerts_page.dart)
  final bool vibration;
  final double vibrationIntensity; // 0-100
  final bool sound;
  final double volumeIntensity; // 0-100

  // Configuraciones de obstáculos específicos
  final bool alertPeople;
  final bool alertStairs;
  final bool alertCars;
  final bool alertMotorcycles;
  final bool alertDogs;
  final bool alertTrees;
  final bool alertEscalators;
  final bool alertCrosswalkState;

  // Configuraciones de distancia
  final double minDistance;
  final double maxDistance;

  const BleConfig({
    required this.vibration,
    required this.vibrationIntensity,
    required this.sound,
    required this.volumeIntensity,
    required this.alertPeople,
    required this.alertStairs,
    required this.alertCars,
    required this.alertMotorcycles,
    required this.alertDogs,
    required this.alertTrees,
    required this.alertEscalators,
    required this.alertCrosswalkState,
    this.minDistance = 0.5,
    this.maxDistance = 5.0,
  });

  /// Factory constructor para crear desde SharedPreferences
  factory BleConfig.fromPreferences(Map<String, dynamic> prefs) {
    return BleConfig(
      vibration: prefs['vibration'] ?? false,
      vibrationIntensity: (prefs['vibration_intensity'] ?? 50.0).toDouble(),
      sound: prefs['sound'] ?? true,
      volumeIntensity: (prefs['volume_intensity'] ?? 50.0).toDouble(),
      alertPeople: prefs['alert_people'] ?? true,
      alertStairs: prefs['alert_stairs'] ?? false,
      alertCars: prefs['alert_cars'] ?? true,
      alertMotorcycles: prefs['alert_motorcycles'] ?? false,
      alertDogs: prefs['alert_dogs'] ?? true,
      alertTrees: prefs['alert_tree'] ?? false,
      alertEscalators: prefs['alert_escalator'] ?? false,
      alertCrosswalkState: prefs['alert_crosswalk_state'] ?? true,
      minDistance: (prefs['min_distance'] ?? 0.5).toDouble(),
      maxDistance: (prefs['max_distance'] ?? 5.0).toDouble(),
    );
  }

  /// Convierte a JSON para enviar vía BLE a la Raspberry Pi
  Map<String, dynamic> toJson() {
    return {
      'vibration': vibration,
      'vibration_intensity': vibrationIntensity,
      'sound': sound,
      'volume_intensity': volumeIntensity,
      'alerts_enabled': _getEnabledAlerts(),
      'min_distance': minDistance,
      'max_distance': maxDistance,
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Convierte a String JSON para enviar vía BLE
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Obtiene lista de alertas habilitadas
  List<String> _getEnabledAlerts() {
    List<String> enabled = [];
    
    if (alertPeople) enabled.add('person');
    if (alertStairs) enabled.add('stairs');
    if (alertCars) enabled.add('car');
    if (alertMotorcycles) enabled.add('motorcycle');
    if (alertDogs) enabled.add('dog');
    if (alertTrees) enabled.add('tree');
    if (alertEscalators) enabled.add('escalator');
    if (alertCrosswalkState) enabled.add('traffic_light');
    
    return enabled;
  }

  /// Verifica si un tipo de obstáculo está habilitado
  bool isObstacleEnabled(String obstacle) {
    switch (obstacle.toLowerCase()) {
      case 'person':
      case 'people':
        return alertPeople;
      case 'stairs':
      case 'escalera':
        return alertStairs;
      case 'car':
      case 'auto':
        return alertCars;
      case 'motorcycle':
      case 'moto':
        return alertMotorcycles;
      case 'dog':
      case 'perro':
        return alertDogs;
      case 'tree':
      case 'árbol':
        return alertTrees;
      case 'escalator':
      case 'escalera mecánica':
        return alertEscalators;
      case 'traffic_light':
      case 'semáforo':
        return alertCrosswalkState;
      default:
        return false;
    }
  }

  /// Verifica si la distancia está en el rango configurado
  bool isDistanceInRange(double distance) {
    return distance >= minDistance && distance <= maxDistance;
  }

  /// Crea una copia con nuevos valores
  BleConfig copyWith({
    bool? vibration,
    double? vibrationIntensity,
    bool? sound,
    double? volumeIntensity,
    bool? alertPeople,
    bool? alertStairs,
    bool? alertCars,
    bool? alertMotorcycles,
    bool? alertDogs,
    bool? alertTrees,
    bool? alertEscalators,
    bool? alertCrosswalkState,
    double? minDistance,
    double? maxDistance,
  }) {
    return BleConfig(
      vibration: vibration ?? this.vibration,
      vibrationIntensity: vibrationIntensity ?? this.vibrationIntensity,
      sound: sound ?? this.sound,
      volumeIntensity: volumeIntensity ?? this.volumeIntensity,
      alertPeople: alertPeople ?? this.alertPeople,
      alertStairs: alertStairs ?? this.alertStairs,
      alertCars: alertCars ?? this.alertCars,
      alertMotorcycles: alertMotorcycles ?? this.alertMotorcycles,
      alertDogs: alertDogs ?? this.alertDogs,
      alertTrees: alertTrees ?? this.alertTrees,
      alertEscalators: alertEscalators ?? this.alertEscalators,
      alertCrosswalkState: alertCrosswalkState ?? this.alertCrosswalkState,
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }

  @override
  String toString() {
    return 'BleConfig(vibration: $vibration, sound: $sound, enabled_alerts: ${_getEnabledAlerts().length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BleConfig &&
        other.vibration == vibration &&
        other.vibrationIntensity == vibrationIntensity &&
        other.sound == sound &&
        other.volumeIntensity == volumeIntensity &&
        other.alertPeople == alertPeople &&
        other.alertStairs == alertStairs &&
        other.alertCars == alertCars &&
        other.alertMotorcycles == alertMotorcycles &&
        other.alertDogs == alertDogs &&
        other.alertTrees == alertTrees &&
        other.alertEscalators == alertEscalators &&
        other.alertCrosswalkState == alertCrosswalkState &&
        other.minDistance == minDistance &&
        other.maxDistance == maxDistance;
  }

  @override
  int get hashCode {
    return Object.hash(
      vibration,
      vibrationIntensity,
      sound,
      volumeIntensity,
      alertPeople,
      alertStairs,
      alertCars,
      alertMotorcycles,
      alertDogs,
      alertTrees,
      alertEscalators,
      alertCrosswalkState,
      minDistance,
      maxDistance,
    );
  }
}