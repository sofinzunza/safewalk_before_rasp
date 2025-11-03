import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);

ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(true);

// Notificador para el estado de alertas
ValueNotifier<int> alertStateNotifier = ValueNotifier(
  1,
); // Estado inicial: solo sonido
