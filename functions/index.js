/**
 * Cloud Functions para SafeWalk
 * Envía notificaciones push cuando se activa una emergencia SOS
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const {setGlobalOptions} = require("firebase-functions/v2");

admin.initializeApp();

// Configuración global
setGlobalOptions({maxInstances: 10});

/**
 * Cloud Function que envía notificaciones push cuando se crea
 * un evento de emergencia.
 */
exports.sendEmergencyNotification = onDocumentCreated(
    "emergency_events/{eventId}",
    async (event) => {
      const eventData = event.data.data();

      if (!eventData || eventData.status !== "active") return null;

      // Obtener el perfil del usuario que activó la emergencia
      const userDoc = await admin.firestore()
          .collection("users")
          .doc(eventData.userId)
          .get();

      if (!userDoc.exists) return null;

      const userData = userDoc.data();
      const userName = userData.name || "Un usuario";
      const emergencyContactIds = eventData.notifiedContactIds || [];

      // Obtener los FCM tokens de los contactos de emergencia
      const contactPromises = emergencyContactIds.map((contactId) =>
        admin.firestore().collection("users").doc(contactId).get(),
      );

      const contactDocs = await Promise.all(contactPromises);
      const tokens = contactDocs
          .filter((doc) => doc.exists && doc.data().fcmToken)
          .map((doc) => doc.data().fcmToken);

      if (tokens.length === 0) {
        console.log("No FCM tokens found for emergency contacts");
        return null;
      }

      // Crear el mensaje de notificación
      const message = {
        notification: {
          title: "🚨 ALERTA SOS",
          body: `¡${userName} necesita ayuda! Ve la ubicación en tiempo real`,
        },
        data: {
          type: "emergency_alert",
          userId: eventData.userId,
          userName: userName,
          lat: String(eventData.lat || 0),
          lng: String(eventData.lng || 0),
          eventId: event.params.eventId,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          priority: "high",
          notification: {
            channelId: "emergency_channel",
            priority: "max",
            sound: "default",
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              "alert": {
                title: "🚨 ALERTA SOS",
                body:
                  `¡${userName} necesita ayuda! ` +
                  `Ve la ubicación en tiempo real`,
              },
              "sound": "default",
              "badge": 1,
              "interruption-level": "critical",
            },
          },
        },
        tokens: tokens,
      };

      // Enviar las notificaciones
      try {
        const response = await admin.messaging().sendEachForMulticast(message);
        const msg = `Successfully sent ${response.successCount} notifications`;
        console.log(msg);
        console.log(`Failed to send ${response.failureCount} notifications`);
        return response;
      } catch (error) {
        console.error("Error sending notifications:", error);
        return null;
      }
    },
);



