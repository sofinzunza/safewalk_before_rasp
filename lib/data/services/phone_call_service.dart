import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

/// Servicio para realizar llamadas telefónicas
class PhoneCallService {
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      if (cleanNumber.isEmpty) {
        developer.log(
          '❌ Número telefónico vacío o inválido',
          name: 'PhoneCallService',
        );
        return false;
      }

      developer.log(
        '📞 Intentando llamar a: $cleanNumber',
        name: 'PhoneCallService',
      );
      if (Platform.isAndroid) {
        try {
          await FlutterPhoneDirectCaller.callNumber(cleanNumber);
          developer.log(
            '✅ Llamada directa iniciada en Android',
            name: 'PhoneCallService',
          );
          return true;
        } catch (e) {
          developer.log(
            '❌ Error en llamada directa Android: $e',
            name: 'PhoneCallService',
          );
          return false;
        }
      }
      final uri = Uri(scheme: 'tel', path: cleanNumber);

      if (await canLaunchUrl(uri)) {
        final result = await launchUrl(uri);
        if (result) {
          developer.log(
            '✅ Llamada iniciada en iOS (requiere confirmación)',
            name: 'PhoneCallService',
          );
        } else {
          developer.log(
            '❌ No se pudo iniciar la llamada en iOS',
            name: 'PhoneCallService',
          );
        }
        return result;
      } else {
        developer.log(
          '❌ No se puede realizar llamadas en este dispositivo',
          name: 'PhoneCallService',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        '❌ Error al realizar llamada: $e',
        name: 'PhoneCallService',
      );
      return false;
    }
  }

  Future<bool> canMakePhoneCalls() async {
    try {
      final uri = Uri(scheme: 'tel', path: '');
      return await canLaunchUrl(uri);
    } catch (e) {
      developer.log(
        '❌ Error verificando capacidad de llamadas: $e',
        name: 'PhoneCallService',
      );
      return false;
    }
  }
}

// Instancia global
final phoneCallService = PhoneCallService();
