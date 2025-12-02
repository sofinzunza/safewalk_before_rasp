import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);

ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(true);

// Notificador para el estado de alertas
ValueNotifier<int> alertStateNotifier = ValueNotifier(
  1,
); // Estado inicial: solo sonido

// Notificador para el estado de alertas de semáforo peatonal
ValueNotifier<bool> crosswalkAlertsNotifier = ValueNotifier(true);

// Notificador para cambios en la configuración de alertas (timestamp)
// Se usa para notificar a home_page que debe actualizar la configuración BLE
ValueNotifier<int> configurationChangedNotifier = ValueNotifier(0);
