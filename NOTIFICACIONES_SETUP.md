# Configuración de Notificaciones Push para SafeWalk

## 🚀 Funcionalidad Implementada

Las notificaciones push están configuradas para enviar alertas inmediatas a los contactos de emergencia cuando un usuario con discapacidad visual activa el botón SOS.

### Características:
- ✅ Notificaciones en tiempo real cuando se activa el SOS
- ✅ Notificaciones en primer plano y segundo plano
- ✅ Diálogos de alerta dentro de la app
- ✅ Mensaje: "🚨 ALERTA SOS: ¡[Nombre] necesita ayuda! Ve la ubicación en tiempo real"
- ✅ Vibración y sonido de alta prioridad
- ✅ Navegación directa al mapa de ubicación
- ✅ Guardado de FCM tokens en Firestore

## 📱 Configuración de Android

### Permisos agregados en AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
```

### Canal de notificaciones:
- **ID**: `emergency_channel`
- **Nombre**: Emergencias
- **Importancia**: MAX
- **Sonido**: Activado
- **Vibración**: Activada
- **Full Screen Intent**: Activado (para alertas críticas)

## 🍎 Configuración de iOS

### Permisos agregados en Info.plist:
- Background modes: `fetch`, `remote-notification`
- User notification settings configurados

### Nivel de interrupción:
- **Critical** para emergencias
- Sonido y vibración habilitados
- Badges activados

## 🔥 Firebase Cloud Messaging - Configuración del Backend

### Opción 1: Firebase Cloud Functions (Recomendado)

Necesitas crear una Cloud Function que escuche cuando se crea un nuevo evento de emergencia y envíe notificaciones:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendEmergencyNotification = functions.firestore
  .document('emergency_events/{eventId}')
  .onCreate(async (snap, context) => {
    const eventData = snap.data();
    
    if (eventData.status !== 'active') return null;
    
    // Obtener el perfil del usuario que activó la emergencia
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(eventData.userId)
      .get();
    
    if (!userDoc.exists) return null;
    
    const userData = userDoc.data();
    const userName = userData.name || 'Un usuario';
    const emergencyContactIds = eventData.notifiedContactIds || [];
    
    // Obtener los FCM tokens de los contactos de emergencia
    const contactPromises = emergencyContactIds.map(contactId =>
      admin.firestore().collection('users').doc(contactId).get()
    );
    
    const contactDocs = await Promise.all(contactPromises);
    const tokens = contactDocs
      .filter(doc => doc.exists && doc.data().fcmToken)
      .map(doc => doc.data().fcmToken);
    
    if (tokens.length === 0) {
      console.log('No FCM tokens found for emergency contacts');
      return null;
    }
    
    // Crear el mensaje de notificación
    const message = {
      notification: {
        title: '🚨 ALERTA SOS',
        body: `¡${userName} necesita ayuda! Ve la ubicación en tiempo real`,
      },
      data: {
        type: 'emergency_alert',
        userId: eventData.userId,
        userName: userName,
        lat: String(eventData.lat || 0),
        lng: String(eventData.lng || 0),
        eventId: context.params.eventId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'emergency_channel',
          priority: 'max',
          sound: 'default',
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: '🚨 ALERTA SOS',
              body: `¡${userName} necesita ayuda! Ve la ubicación en tiempo real`,
            },
            sound: 'default',
            badge: 1,
            'interruption-level': 'critical',
          },
        },
      },
      tokens: tokens,
    };
    
    // Enviar las notificaciones
    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`Successfully sent ${response.successCount} notifications`);
      console.log(`Failed to send ${response.failureCount} notifications`);
      return response;
    } catch (error) {
      console.error('Error sending notifications:', error);
      return null;
    }
  });
```

### Opción 2: Servidor Backend Propio

Si tienes tu propio servidor backend, puedes usar la Firebase Admin SDK:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./path/to/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function sendEmergencyNotification(userId, userName, lat, lng, tokens) {
  const message = {
    notification: {
      title: '🚨 ALERTA SOS',
      body: `¡${userName} necesita ayuda! Ve la ubicación en tiempo real`,
    },
    data: {
      type: 'emergency_alert',
      userId: userId,
      userName: userName,
      lat: String(lat || 0),
      lng: String(lng || 0),
    },
    tokens: tokens,
  };
  
  const response = await admin.messaging().sendEachForMulticast(message);
  return response;
}
```

## 🔧 Pasos para Implementar Cloud Functions

1. **Instalar Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Inicializar Functions en tu proyecto**:
   ```bash
   cd /Users/sofiainzunza/Development/Projects/safewalk
   firebase init functions
   ```

3. **Seleccionar**:
   - JavaScript o TypeScript (recomiendo JavaScript para simplicidad)
   - Instalar dependencias

4. **Copiar el código de la función** en `functions/index.js`

5. **Desplegar**:
   ```bash
   firebase deploy --only functions
   ```

## 📊 Estructura de Datos en Firestore

### Token FCM en perfil de usuario:
```javascript
users/{userId}
  ├─ fcmToken: "token_aqui"
  ├─ name: "Sofia"
  ├─ emergencyContactIds: ["contactId1", "contactId2"]
  └─ ...
```

### Notificaciones guardadas:
```javascript
users/{contactId}/notifications/{notificationId}
  ├─ type: "emergency_alert"
  ├─ title: "🚨 ALERTA SOS"
  ├─ body: "¡Sofia necesita ayuda!..."
  ├─ userId: "userId_del_usuario_en_emergencia"
  ├─ userName: "Sofia"
  ├─ lat: -33.447
  ├─ lng: -70.673
  ├─ timestamp: Timestamp
  └─ read: false
```

## 🧪 Testing

### Probar notificaciones locales:
Las notificaciones locales ya funcionan automáticamente cuando se activa el SOS. Puedes probarlas:

1. Asegúrate de tener contactos de emergencia configurados
2. Activa el botón SOS
3. Deberías ver una notificación local inmediata

### Probar notificaciones push (requiere Cloud Functions):
1. Despliega las Cloud Functions
2. Activa el SOS desde un dispositivo
3. Los contactos de emergencia deberían recibir la notificación push

## ⚠️ Notas Importantes

1. **FCM Tokens**: Los tokens se guardan automáticamente cuando el usuario inicia sesión
2. **Actualización de tokens**: Los tokens se actualizan automáticamente cuando cambian
3. **Permisos**: Los usuarios deben aceptar los permisos de notificaciones
4. **iOS**: Para notificaciones críticas en producción, necesitas un perfil de aprovisionamiento especial de Apple
5. **Testing en iOS**: Usa un dispositivo físico, no funciona en simulador

## 🔒 Seguridad

- Las notificaciones solo se envían a contactos de emergencia registrados
- Los tokens FCM están protegidos en Firestore
- Las reglas de Firestore deben permitir que solo el usuario pueda leer/escribir su propio token

### Reglas de Firestore recomendadas:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /notifications/{notificationId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    match /emergency_events/{eventId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                      (resource.data.userId == request.auth.uid || 
                       request.auth.uid in resource.data.notifiedContactIds);
    }
  }
}
```

## 📝 Próximos Pasos

1. ✅ Notificaciones locales - Implementado
2. ✅ Guardado de datos de notificación en Firestore - Implementado
3. ⏳ Implementar Cloud Functions - Pendiente
4. ⏳ Configurar reglas de seguridad de Firestore - Pendiente
5. ⏳ Testing en dispositivos físicos - Pendiente

## 🆘 Troubleshooting

### Las notificaciones no aparecen en Android:
- Verifica que los permisos estén otorgados
- Revisa que el canal de notificaciones esté creado
- Comprueba los logs con `flutter logs`

### Las notificaciones no aparecen en iOS:
- Usa un dispositivo físico, no simulador
- Verifica que los permisos estén aceptados
- Revisa las configuraciones de Capabilities en Xcode

### Los tokens no se guardan:
- Verifica que Firebase esté inicializado correctamente
- Revisa que el usuario esté autenticado
- Comprueba las reglas de Firestore
