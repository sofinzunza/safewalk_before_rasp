import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/alert_utils.dart';
import 'package:safewalk/views/pages/home_page.dart';
import 'package:safewalk/views/widgets/nextbutton_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWelcomePage extends StatefulWidget {
  const SettingsWelcomePage({super.key});

  @override
  State<SettingsWelcomePage> createState() => _SettingsWelcomePageState();
}

class _SettingsWelcomePageState extends State<SettingsWelcomePage> {
  // Claves compartidas con alerts_page.dart
  static const _kVibration = 'vibration';
  static const _kSound = 'sound';

  bool vibration = false;
  bool sound = true;

  bool aCrosswalkState = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    final crosswalkState = await AlertUtils.getCrosswalkAlertState();

    setState(() {
      vibration = p.getBool(_kVibration) ?? vibration;
      sound = p.getBool(_kSound) ?? sound;
      aCrosswalkState = crosswalkState;
    });
  }

  Future<void> _saveBool(String k, bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(k, v);
  }

  Future<void> _saveCrosswalkState(bool v) async {
    await AlertUtils.setCrosswalkAlertState(v);
  }

  @override
  Widget build(BuildContext context) {
    final active = KColors.tealChillon;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 80, 25, 30),
              decoration: BoxDecoration(
                color: KColors.lightTeal,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    button: true,
                    label: 'Regresar',
                    hint: 'Volver a la pantalla anterior',
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Semantics(
                          header: true,
                          label: 'Comencemos a configurar tu gorro',
                          child: const Text(
                            'Comencemos a\nconfigurar tu gorro!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          label:
                              'Configura qué tipo de alertas deseas recibir y de qué. Luego podrás configurar más detalladamente.',
                          child: Text(
                            'Configura que tipo de alertas deseas recibir y de que, luego podras configurar más detalladamente',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Configura que tipo de alertas\nquieres recibir:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _Switch(
                    icon: Icons.volume_up,
                    title: 'Alertas de Sonido',
                    value: sound,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => sound = v);
                      _saveBool(_kSound, v);
                    },
                  ),
                  _Switch(
                    icon: Icons.vibration,
                    title: 'Alertas de Vibración',
                    value: vibration,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => vibration = v);
                      _saveBool(_kVibration, v);
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  const Text(
                    'Configura que alertas quieres\nrecibir:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _Switch(
                    icon: Icons.traffic,
                    title: 'Alertas de Estado de Semáforo Peatonal',
                    value: aCrosswalkState,
                    activeColor: active,
                    onChanged: (v) async {
                      setState(() => aCrosswalkState = v);
                      await _saveCrosswalkState(v);
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    child: const Text(
                      'Omitir',
                      style: TextStyle(
                        color: KColors.tealChillon,
                        decoration: TextDecoration.underline,
                        decorationColor: KColors.tealChillon,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Spacer(),
                  NextButton(
                    text: 'Siguiente',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//* Widgets
class _Switch extends StatelessWidget {
  const _Switch({
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
    return Semantics(
      label: title,
      value: value ? 'Activado' : 'Desactivado',
      toggled: value,
      onTap: () => onChanged(!value),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Icon(icon),
        title: Text(title),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: activeColor,
        ),
      ),
    );
  }
}
