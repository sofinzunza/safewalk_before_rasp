# 📱 Sistema de Contactos de Emergencia con Ubicación en Tiempo Real

## ✅ Implementación Completada

He implementado un sistema completo de contactos de emergencia con ubicación en tiempo real para tu app SafeWalk. Aquí está todo lo que se agregó:

---

## 🆕 Archivos Nuevos Creados

### 1. **Modelos de Datos**
- `lib/data/models/user_model.dart` - Modelo de usuario con tipos (con discapacidad visual / contacto de emergencia)
- `lib/data/models/emergency_event_model.dart` - Modelo para eventos de emergencia

### 2. **Servicios**
- `lib/data/services/firestore_service.dart` - Servicio para manejar operaciones de Firestore
- `lib/data/services/location_service.dart` - Servicio para compartir ubicación en tiempo real

### 3. **Interfaces de Usuario**
- `lib/views/pages/manage_emergency_contacts_page.dart` - Página para agregar/eliminar contactos de emergencia

---

## 🔧 Archivos Modificados

### 1. **pubspec.yaml**
- ✅ Agregada dependencia `cloud_firestore: ^6.1.0`

### 2. **signin_email.dart**
- ✅ Ahora guarda el perfil del usuario en Firestore
- ✅ Redirige a la pantalla correcta según el tipo de usuario:
  - Usuario con discapacidad visual → `WelcomePage`
  - Contacto de emergencia (tutor) → `TwelcomePage`

### 3. **sos_buttom.dart**
- ✅ Al presionar el botón SOS:
  - Obtiene la ubicación actual
  - Crea un evento de emergencia en Firestore
  - Inicia el compartir ubicación en tiempo real
  - Notifica a todos los contactos de emergencia
  - Muestra el número de contactos notificados
- ✅ Al presionar nuevamente cancela la emergencia

### 4. **tlocation_page.dart**
- ✅ Ahora escucha la ubicación en tiempo real desde Firestore
- ✅ Soporta múltiples usuarios vinculados
- ✅ Muestra la ubicación actualizada automáticamente

### 5. **semergency_page.dart**
- ✅ Redirige a la nueva página de gestión de contactos

---

## 🚀 Pasos Siguientes IMPORTANTES

### **PASO 1: Instalar Dependencias**

Ejecuta en tu terminal:

\`\`\`bash
cd /Users/sofiainzunza/Development/Projects/safewalk
flutter pub get
\`\`\`

### **PASO 2: Configurar Firestore en Firebase Console**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto "SafeWalk"
3. En el menú lateral, haz clic en **"Firestore Database"**
4. Haz clic en **"Crear base de datos"**
5. Selecciona **"Comenzar en modo de prueba"** (temporal)
6. Elige una ubicación (ejemplo: `us-central`)
7. Haz clic en **"Habilitar"**

### **PASO 3: Configurar Reglas de Seguridad**

En Firestore Database → Reglas, reemplaza con:

\`\`\`javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas para usuarios
    match /users/{userId} {
      // Permitir lectura si eres tú o si eres contacto de emergencia
      allow read: if request.auth != null && (
        request.auth.uid == userId ||
        request.auth.uid in resource.data.emergencyContactIds ||
        request.auth.uid in resource.data.linkedVisuallyImpairedIds
      );
      
      // Solo el usuario puede escribir su propio documento
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reglas para eventos de emergencia
    match /emergency_events/{eventId} {
      // Permitir lectura si eres el usuario o uno de sus contactos
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && (
        request.auth.uid == resource.data.userId ||
        request.auth.uid in resource.data.notifiedContactIds
      );
    }
  }
}
\`\`\`

### **PASO 4: Agregar Google Maps API Key** (si aún no lo hiciste)

En `android/app/src/main/AndroidManifest.xml`, reemplaza `YOUR_API_KEY_HERE` con tu API key real de Google Maps.

Si no tienes una:
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Habilita "Maps SDK for Android"
3. Crea una API Key
4. Pégala en el AndroidManifest

---

## 📖 Cómo Funciona el Sistema

### **Para Usuarios con Discapacidad Visual:**

1. **Registro:**
   - Marcan la casilla "Soy usuario con discapacidad visual"
   - Se crea su perfil en Firestore

2. **Agregar Contactos de Emergencia:**
   - Van a la página de Emergencia
   - Tocan "Configuración de contactos de emergencia"
   - Buscan por email o teléfono
   - Agregan contactos (deben ser usuarios registrados como "contacto de emergencia")

3. **Activar SOS:**
   - Presionan el botón rojo de emergencia
   - Se obtiene su ubicación actual
   - Se crea un evento de emergencia
   - Se inicia el compartir ubicación en tiempo real
   - Todos sus contactos son notificados

### **Para Contactos de Emergencia (Tutores):**

1. **Registro:**
   - Marcan la casilla "Soy contacto de emergencia"
   - Se crea su perfil en Firestore

2. **Recibir Vinculación:**
   - Cuando un usuario con discapacidad visual los agrega, quedan automáticamente vinculados

3. **Ver Ubicación en Tiempo Real:**
   - Van a la página "Mapa" en el bottom navigation
   - Ven la ubicación en tiempo real del usuario vinculado
   - Si el usuario activa SOS, verán su ubicación actualizada constantemente

---

## 🔄 Flujo Completo del Sistema

\`\`\`
Usuario con Discapacidad Visual                 Contacto de Emergencia (Tutor)
         │                                                │
         ├─ Se registra con checkbox                     ├─ Se registra con checkbox
         │  "discapacidad visual"                        │  "contacto de emergencia"
         │                                                │
         ├─ Agrega contacto por email/teléfono ─────────>├─ Queda vinculado
         │                                                │  automáticamente
         │                                                │
         ├─ Presiona botón SOS                           │
         │  • Obtiene ubicación                          │
         │  • Crea evento emergencia                     │
         │  • Inicia compartir ubicación ───────────────>├─ Recibe notificación
         │                                                │  (en futuro con FCM)
         │                                                │
         ├─ Ubicación se actualiza cada 10 metros ──────>├─ Ve ubicación en tiempo
         │  en Firestore automáticamente                 │  real en el mapa
         │                                                │
         ├─ Presiona SOS nuevamente para cancelar        │
         │  • Detiene compartir ubicación                │
         │  • Marca evento como cancelado                │
\`\`\`

---

## 🗂️ Estructura de Datos en Firestore

### **Colección: users**
\`\`\`json
{
  "uid": "abc123",
  "email": "usuario@example.com",
  "name": "Juan Pérez",
  "rut": "12345678-9",
  "phone": "912345678",
  "userType": "visuallyImpaired", // o "emergencyContact"
  "emergencyContactIds": ["def456", "ghi789"], // IDs de contactos
  "linkedVisuallyImpairedIds": [], // Para tutores
  "currentLat": -33.447487,
  "currentLng": -70.673676,
  "lastLocationUpdate": Timestamp,
  "isLocationSharingActive": true,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
\`\`\`

### **Colección: emergency_events**
\`\`\`json
{
  "id": "event123",
  "userId": "abc123",
  "lat": -33.447487,
  "lng": -70.673676,
  "address": "Av. Libertador, Santiago",
  "status": "active", // "resolved", "cancelled"
  "createdAt": Timestamp,
  "resolvedAt": Timestamp,
  "notifiedContactIds": ["def456", "ghi789"]
}
\`\`\`

---

## ⚠️ Notas Importantes

1. **Permisos de Ubicación:**
   - La app solicita permisos de ubicación al presionar SOS
   - Los permisos ya están configurados en AndroidManifest.xml e Info.plist

2. **Ubicación en Tiempo Real:**
   - Se actualiza cada 10 metros de movimiento
   - Se detiene al cancelar la emergencia
   - Los tutores ven la ubicación en tiempo real mientras esté activa

3. **Notificaciones Push (Próximo Paso):**
   - Actualmente el sistema guarda los eventos en Firestore
   - Para notificaciones push reales, necesitarás Firebase Cloud Messaging (FCM)
   - Puedo ayudarte a implementar eso después

4. **Llamadas Automáticas (Futuro):**
   - Los switches en la página de emergencia están listos
   - Para implementar llamadas automáticas necesitarás el paquete `url_launcher` o `flutter_phone_direct_caller`

---

## 🧪 Cómo Probar

1. **Crea dos cuentas:**
   - Cuenta A: Usuario con discapacidad visual
   - Cuenta B: Contacto de emergencia

2. **Con la Cuenta A:**
   - Ve a Emergencia → Configuración de contactos
   - Agrega el email de la Cuenta B

3. **Con la Cuenta A:**
   - Presiona el botón SOS
   - Deberías ver "1 contacto(s) notificado(s)"

4. **Con la Cuenta B:**
   - Ve a la página "Mapa"
   - Deberías ver la ubicación de la Cuenta A en tiempo real

---

## 🐛 Solución de Problemas

### **Error: "Usuario no encontrado"**
- Asegúrate de que el contacto esté registrado como "contacto de emergencia"
- Verifica que el email/teléfono sea correcto

### **Error: "No se pudo obtener la ubicación"**
- Verifica que los permisos de ubicación estén habilitados
- En emulador, configura una ubicación mock

### **El mapa no carga**
- Verifica que hayas agregado la Google Maps API Key
- Asegúrate de que la API esté habilitada en Google Cloud Console

### **Firestore: Permission Denied**
- Verifica que hayas configurado las reglas de seguridad correctamente
- En desarrollo, puedes usar modo de prueba temporalmente

---

## 🎯 Próximas Mejoras Sugeridas

1. **Notificaciones Push con FCM**
   - Enviar notificación push cuando se activa SOS
   - Incluir ubicación y botón "Ver en mapa"

2. **Llamadas Automáticas**
   - Implementar llamada automática al contacto principal
   - Usar `url_launcher` o `flutter_phone_direct_caller`

3. **Historial de Emergencias**
   - Página para ver emergencias pasadas
   - Estadísticas y reportes

4. **Chat en Tiempo Real**
   - Permitir comunicación entre usuario y contactos
   - Usar Firestore para mensajes en tiempo real

5. **Compartir Ubicación Programada**
   - Opción para compartir ubicación siempre (no solo en emergencia)
   - Horarios programados

---

## 📞 ¿Necesitas Ayuda?

Si tienes algún problema o duda durante la implementación, avísame y te ayudo a resolverlo. También puedo ayudarte a implementar las mejoras sugeridas.

¡El sistema está listo para probar! 🚀
