import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Notifier global para el idioma
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('es'));

class LanguageService {
  static const String _languageKey = 'selected_language';

  // Cargar idioma guardado
  static Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'es';
    localeNotifier.value = Locale(languageCode);
  }

  // Guardar idioma seleccionado
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    localeNotifier.value = Locale(languageCode);
  }

  // Obtener idioma actual
  static String getCurrentLanguage() {
    return localeNotifier.value.languageCode;
  }
}
