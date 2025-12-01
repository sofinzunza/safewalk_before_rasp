import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/views/pages/semergency_page.dart';
import 'package:safewalk/views/widgets/sos_buttom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  static const _cEmergency = 'call_emergency';
  static const _sLocation = 'send_location';

  bool cEmergency = true;
  bool sLocation = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      cEmergency = p.getBool(_cEmergency) ?? cEmergency;
      sLocation = p.getBool(_sLocation) ?? sLocation;
    });
  }

  Future<void> _saveBool(String k, bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(k, v);
  }

  @override
  Widget build(BuildContext context) {
    final active = KColors.tealChillon; // color del switch/slider
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 45),
              const Text(
                'S.O.S',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Center(
                child: SizedBox(
                  width: 300,
                  height: 290,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SosButtom(
                        shouldSendLocation: sLocation,
                        shouldCallEmergency: cEmergency,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SwitchTile(
                icon: Icons.call,
                title: 'Llamada a contacto de emergencia',
                value: cEmergency,
                activeColor: active,
                onChanged: (v) {
                  setState(() => cEmergency = v);
                  _saveBool(_cEmergency, v);
                },
              ),
              _SwitchTile(
                icon: Icons.location_on,
                title: 'Envio de ubicación al contacto de emergencia',
                value: sLocation,
                activeColor: active,
                onChanged: (v) {
                  setState(() => sLocation = v);
                  _saveBool(_sLocation, v);
                },
              ),
              const SizedBox(height: 40),
              ListTile(
                title: const Text('Configuración de contactos de emergencia'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SettingsEmergencyContacts();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeColor,
      ),
    );
  }
}
