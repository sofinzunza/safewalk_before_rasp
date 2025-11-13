import 'dart:convert';

/// Modelo para la configuración BLE que se envía a la Raspberry Pi
class BleConfig {
  // Configuraciones de alertas
  final bool vibration; // 'vibration'
  final double vibrationIntensity; // 'vibration_intensity' (0-100)
  final bool sound; // 'sound'
  final double volumeIntensity; // 'volume_intensity' (0-100)

  // Configuraciones de obstáculos específicos
  final bool alertPeople; // 'alert_people'
  final bool alertStairs; // 'alert_stairs'
  final bool alertCars; // 'alert_cars'
  final bool alertMotorcycles; // 'alert_motorcycles'
  final bool alertBikes; // 'alert_bikes'
  final bool alertDogs; // 'alert_dogs'
  final bool alertTree; // 'alert_tree'
  final bool alertDoor; // 'alert_door'
  final bool alertEscalator; // 'alert_escalator'
  final bool alertCrosswalkState; // 'alert_crosswalk_state'

  // Configuraciones de distancia (para la Raspberry Pi)
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
    required this.alertBikes,
    required this.alertDogs,
    required this.alertTree,
    required this.alertDoor,
    required this.alertEscalator,
    required this.alertCrosswalkState,
    this.minDistance = 0.5,
    this.maxDistance = 5.0,
  });

  /// ✅ Factory constructor desde SharedPreferences con CLAVES EXACTAS
  factory BleConfig.fromPreferences(Map<String, dynamic> prefs) {
    return BleConfig(
      // Configuraciones de alertas
      vibration: prefs['vibration'] ?? false,
      vibrationIntensity: (prefs['vibration_intensity'] ?? 50.0).toDouble(),
      sound: prefs['sound'] ?? true,
      volumeIntensity: (prefs['volume_intensity'] ?? 50.0).toDouble(),

      // Configuraciones de obstáculos (EXACTAS de tu alerts_page.dart)
      alertPeople: prefs['alert_people'] ?? true,
      alertStairs: prefs['alert_stairs'] ?? false,
      alertCars: prefs['alert_cars'] ?? true,
      alertMotorcycles: prefs['alert_motorcycles'] ?? false,
      alertBikes: prefs['alert_bikes'] ?? false,
      alertDogs: prefs['alert_dogs'] ?? true,
      alertTree: prefs['alert_tree'] ?? false,
      alertDoor: prefs['alert_door'] ?? true,
      alertEscalator: prefs['alert_escalator'] ?? false,
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

  /// ✅ Obtiene lista de alertas habilitadas (SINCRONIZADO con tu UI)
  List<String> _getEnabledAlerts() {
    List<String> enabled = [];

    if (alertPeople) enabled.add('person');
    if (alertStairs) enabled.add('stairs');
    if (alertCars) enabled.add('car');
    if (alertMotorcycles) enabled.add('motorcycle');
    if (alertBikes) enabled.add('bicycle');
    if (alertDogs) enabled.add('dog');
    if (alertTree) enabled.add('tree');
    if (alertDoor) enabled.add('door');
    if (alertEscalator) enabled.add('escalator');
    if (alertCrosswalkState) enabled.add('traffic_light');

    return enabled;
  }

  /// ✅ Verifica si un tipo de obstáculo está habilitado
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
      case 'bicycle':
      case 'bike':
      case 'bicicleta':
        return alertBikes;
      case 'dog':
      case 'perro':
        return alertDogs;
      case 'tree':
      case 'árbol':
        return alertTree;
      case 'door':
      case 'puerta':
        return alertDoor;
      case 'escalator':
      case 'escalera mecánica':
        return alertEscalator;
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
    bool? alertBikes,
    bool? alertDogs,
    bool? alertTree,
    bool? alertDoor,
    bool? alertEscalator,
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
      alertBikes: alertBikes ?? this.alertBikes,
      alertDogs: alertDogs ?? this.alertDogs,
      alertTree: alertTree ?? this.alertTree,
      alertDoor: alertDoor ?? this.alertDoor,
      alertEscalator: alertEscalator ?? this.alertEscalator,
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
        other.alertBikes == alertBikes &&
        other.alertDogs == alertDogs &&
        other.alertTree == alertTree &&
        other.alertDoor == alertDoor &&
        other.alertEscalator == alertEscalator &&
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
      alertBikes,
      alertDogs,
      alertTree,
      alertDoor,
      alertEscalator,
      alertCrosswalkState,
      minDistance,
      maxDistance,
    );
  }
}
