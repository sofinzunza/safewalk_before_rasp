# 📖 Guía de Uso del Sistema de Idiomas

## ✅ Sistema Implementado

El sistema de cambio de idioma está completamente funcional con:
- ✅ **9 idiomas disponibles**: Español, Inglés, Chino, Alemán, Japonés, Coreano, Tailandés, Portugués, Francés
- ✅ Persistencia con SharedPreferences
- ✅ Cambio en tiempo real sin reiniciar la app
- ✅ Interfaz de usuario completa en `LanguagePage`
- ✅ Traducciones profesionales nativas

## 🌍 Idiomas Soportados

| Idioma | Código | Bandera | Nombre Nativo |
|--------|--------|---------|---------------|
| Español | `es` | 🇪🇸 | Español |
| Inglés | `en` | 🇺🇸 | English |
| Chino | `zh` | 🇨🇳 | 中文 |
| Alemán | `de` | 🇩🇪 | Deutsch |
| Japonés | `ja` | 🇯🇵 | 日本語 |
| Coreano | `ko` | 🇰🇷 | 한국어 |
| Tailandés | `th` | 🇹🇭 | ภาษาไทย |
| Portugués | `pt` | 🇵🇹 | Português |
| Francés | `fr` | 🇫🇷 | Français |

## 🎯 Cómo Usar las Traducciones en tus Páginas

### Método 1: Con ValueListenableBuilder (Recomendado para textos dinámicos)

```dart
import 'package:safewalk/data/language_notifier.dart';
import 'package:safewalk/data/localizations.dart';

// En tu widget:
ValueListenableBuilder<Locale>(
  valueListenable: localeNotifier,
  builder: (context, locale, child) {
    final texts = AppLocalizations.of(locale.languageCode);
    
    return Text(texts.settings); // Mostrará el texto en el idioma actual
  },
)
```

### Método 2: Acceso directo (Para textos estáticos)

```dart
import 'package:safewalk/data/language_notifier.dart';
import 'package:safewalk/data/localizations.dart';

// Obtener textos del idioma actual
final currentLang = LanguageService.getCurrentLanguage();
final texts = AppLocalizations.of(currentLang);

// Usar en widgets
Text(texts.welcome)
Text(texts.email)
Text(texts.password)
```

## 📝 Textos Disponibles

### Generales
- `appName`, `welcome`, `settings`, `account`
- `cancel`, `save`, `delete`, `update`, `continue_`, `back`

### Autenticación
- `login`, `register`, `logout`
- `email`, `password`, `forgotPassword`

### Cuenta
- `editProfile`, `changePassword`, `deleteAccount`
- `currentPassword`, `newPassword`, `confirmPassword`

### Configuración
- `language`, `selectLanguage`
- `spanish`, `english`, `chinese`, `german`, `japanese`, `korean`, `thai`, `portuguese`, `french`
- `darkMode`, `notifications`

### Alertas y Bluetooth
- `alerts`, `obstacleAlerts`, `trafficLightAlerts`
- `bluetooth`, `connected`, `disconnected`, `searching`

### Mensajes
- `successfullyUpdated`, `error`, `areYouSure`
- `recoverPassword`, `resetPassword`, `sendEmail`, `emailSent`

## ➕ Agregar Nuevas Traducciones

### Paso 1: Edita `/lib/data/localizations.dart`

Agrega un nuevo getter usando el método `_translate()`:

```dart
String get tuNuevoTexto => _translate({
  'es': 'Texto en español',
  'en': 'Text in English',
  'zh': '中文文本',
  'de': 'Text auf Deutsch',
  'ja': '日本語のテキスト',
  'ko': '한국어 텍스트',
  'th': 'ข้อความภาษาไทย',
  'pt': 'Texto em português',
  'fr': 'Texte en français',
});
```

### Paso 2: Usa la nueva traducción

```dart
final texts = AppLocalizations.of(currentLang);
Text(texts.tuNuevoTexto)
```

## ➕ Agregar un Nuevo Idioma

### Paso 1: Agrega traducciones en `localizations.dart`

Para cada texto existente, agrega la traducción del nuevo idioma:

```dart
String get welcome => _translate({
  'es': 'Bienvenido',
  'en': 'Welcome',
  'zh': '欢迎',
  'de': 'Willkommen',
  'ja': 'ようこそ',
  'ko': '환영합니다',
  'th': 'ยินดีต้อนรับ',
  'pt': 'Bem-vindo',
  'fr': 'Bienvenue',
  'it': 'Benvenuto', // ← Nuevo idioma (Italiano)
});
```

### Paso 2: Agrega el getter del nombre del idioma

```dart
String get italian => _translate({
  'es': 'Italiano',
  'en': 'Italian',
  'zh': '意大利语',
  'de': 'Italienisch',
  'ja': 'イタリア語',
  'ko': '이탈리아어',
  'th': 'ภาษาอิตาลี',
  'pt': 'Italiano',
  'fr': 'Italien',
  'it': 'Italiano',
});
```

### Paso 3: Agrega la opción en `language_page.dart`

Dentro del `ListView` en `language_page.dart`:

```dart
const SizedBox(height: 12),
// Italiano
_LanguageOption(
  languageName: texts.italian,
  nativeName: 'Italiano',
  languageCode: 'it',
  flag: '🇮🇹',
  isSelected: currentLang == 'it',
  onTap: () async {
    await LanguageService.saveLanguage('it');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lingua cambiata in Italiano'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  },
),
```

## 🔄 Cambiar Idioma Programáticamente

```dart
import 'package:safewalk/data/language_notifier.dart';

// Cambiar a español
await LanguageService.saveLanguage('es');

// Cambiar a inglés
await LanguageService.saveLanguage('en');

// Cambiar a japonés
await LanguageService.saveLanguage('ja');

// Obtener idioma actual
String currentLang = LanguageService.getCurrentLanguage();
```

## 📱 Ejemplo Completo de Página

```dart
import 'package:flutter/material.dart';
import 'package:safewalk/data/language_notifier.dart';
import 'package:safewalk/data/localizations.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, child) {
            final texts = AppLocalizations.of(locale.languageCode);
            return Text(texts.settings);
          },
        ),
      ),
      body: ValueListenableBuilder<Locale>(
        valueListenable: localeNotifier,
        builder: (context, locale, child) {
          final texts = AppLocalizations.of(locale.languageCode);
          
          return Column(
            children: [
              Text(texts.welcome),
              ElevatedButton(
                onPressed: () {},
                child: Text(texts.continue_),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

## 🎨 La Página de Idiomas

Ya está implementada en `/lib/views/pages/language_page.dart`:
- Interfaz visual con banderas de cada país
- Lista scrolleable con todos los idiomas
- Selección táctil intuitiva
- Feedback inmediato en el idioma seleccionado
- Guardado automático de preferencia

## 🌟 Características Avanzadas

### Sistema Escalable
- Usa un método `_translate()` que hace fácil agregar idiomas
- Si falta una traducción, usa inglés por defecto
- Estructura limpia y mantenible

### Textos Nativos
- Cada idioma se muestra en su escritura nativa (中文, 日本語, 한국어, etc.)
- Banderas emoji para identificación visual rápida
- Feedback de confirmación en el idioma seleccionado

¡El sistema está listo para usar con 9 idiomas! 🚀🌍
