import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  // ---- Preferencias (claves) ----
  static const _kVibration = 'vibration';
  static const _kVibrationIntensity = 'vibration_intensity'; // 0-100
  static const _kSound = 'sound';
  static const _kVolumeIntensity = 'volume_intensity'; // 0-100

  static const _kPeople = 'alert_people';
  static const _kStairs = 'alert_stairs';
  static const _kCars = 'alert_cars';
  static const _kMotorcycles = 'alert_motorcycles';
  static const _kDogs = 'alert_dogs';
  static const _kTree = 'alert_tree';
  static const _kEscalator = 'alert_escalator';
  static const _kCrosswalkState = 'alert_crosswalk_state';

  // ---- Estado ----
  bool vibration = false;
  double vibrationIntensity = 50;
  bool sound = true;
  double volumeIntensity = 50;

  bool aPeople = true;
  bool aStairs = false;
  bool aCars = true;
  bool aMotorcycles = false;
  bool aDogs = true;
  bool aTree = false;
  bool aEscalator = false;
  bool aCrosswalkState = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      vibration = p.getBool(_kVibration) ?? vibration;
      vibrationIntensity =
          p.getDouble(_kVibrationIntensity) ?? vibrationIntensity;
      sound = p.getBool(_kSound) ?? sound;
      volumeIntensity = p.getDouble(_kVolumeIntensity) ?? volumeIntensity;

      aPeople = p.getBool(_kPeople) ?? aPeople;
      aStairs = p.getBool(_kStairs) ?? aStairs;
      aCars = p.getBool(_kCars) ?? aCars;
      aMotorcycles = p.getBool(_kMotorcycles) ?? aMotorcycles;
      aDogs = p.getBool(_kDogs) ?? aDogs;
      aTree = p.getBool(_kTree) ?? aTree;
      aEscalator = p.getBool(_kEscalator) ?? aEscalator;
      aCrosswalkState = p.getBool(_kCrosswalkState) ?? aCrosswalkState;
    });
  }

  Future<void> _saveBool(String k, bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(k, v);
  }

  Future<void> _saveDouble(String k, double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(k, v);
  }

  @override
  Widget build(BuildContext context) {
    final active = KColors.tealChillon; // color del switch/slider

    return Scaffold(
      backgroundColor: KColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Configuración\nAvanzada',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28.0,
                  fontFamily: "DMSans",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    'Configura qué tipo de alerta quieres recibir:',
                  ),
                  const SizedBox(height: 8),
                  // VIBRACIÓN
                  _SwitchRow(
                    icon: Icons.vibration,
                    title: 'Vibración',
                    value: vibration,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => vibration = v);
                      _saveBool(_kVibration, v);
                    },
                  ),
                  const SizedBox(height: 8),
                  _LabeledSlider(
                    label: 'Intensidad de vibración:',
                    value: vibrationIntensity,
                    enabled: vibration,
                    minIcon: Icons.smartphone,
                    maxIcon: Icons.vibration,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => vibrationIntensity = v);
                      _saveDouble(_kVibrationIntensity, v);
                    },
                  ),

                  const Divider(height: 24),

                  // SONIDO
                  _SwitchRow(
                    icon: Icons.volume_up,
                    title: 'Sonido',
                    value: sound,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => sound = v);
                      _saveBool(_kSound, v);
                    },
                  ),
                  const SizedBox(height: 8),
                  _LabeledSlider(
                    label: 'Intensidad de volumen:',
                    value: volumeIntensity,
                    enabled: sound,
                    minIcon: Icons.volume_mute,
                    maxIcon: Icons.volume_up,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => volumeIntensity = v);
                      _saveDouble(_kVolumeIntensity, v);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Configura las alertas de obstáculos:'),
                  const SizedBox(height: 4),
                  _SwitchTile(
                    icon: Icons.person,
                    title: 'Alertas de Personas',
                    value: aPeople,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => aPeople = v);
                      _saveBool(_kPeople, v);
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.stairs,
                    title: 'Alertas de Escaleras',
                    value: aStairs,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => aStairs = v);
                      _saveBool(_kStairs, v);
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.directions_car,
                    title: 'Alertas de Autos',
                    value: aCars,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => aCars = v);
                      _saveBool(_kCars, v);
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.motorcycle,
                    title: 'Alertas de Motos',
                    value: aMotorcycles,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => aMotorcycles = v);
                      _saveBool(_kMotorcycles, v);
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.pets,
                    title: 'Alertas de Perros',
                    value: aDogs,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => aDogs = v);
                      _saveBool(_kDogs, v);
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.park,
                    title: 'Alertas de Árbol',
                    value: aTree,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => aTree = v);
                      _saveBool(_kTree, v);
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.escalator,
                    title: 'Alertas de Escaleras Mecánicas',
                    value: aEscalator,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => aEscalator = v);
                      _saveBool(_kEscalator, v);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SwitchTile(
                    icon: Icons.traffic,
                    title: 'Alertas de Estado de Semáforo Peatonal',
                    value: aCrosswalkState,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() => aCrosswalkState = v);
                      _saveBool(_kCrosswalkState, v);
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

// ---------- Widgets de apoyo ----------

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KColors.lightaqua,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
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
    return Row(
      children: [
        Icon(icon, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: activeColor,
        ),
      ],
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.enabled,
    required this.minIcon,
    required this.maxIcon,
    required this.activeColor,
  });

  final String label;
  final double value; // 0-100
  final bool enabled;
  final ValueChanged<double> onChanged;
  final IconData minIcon;
  final IconData maxIcon;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final trackColor = enabled ? activeColor : Theme.of(context).disabledColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(minIcon, size: 22),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: trackColor,
                  thumbColor: trackColor,
                ),
                child: Slider(
                  value: value,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '${value.round()}%',
                  onChanged: enabled ? onChanged : null,
                ),
              ),
            ),
            Icon(maxIcon, size: 22),
          ],
        ),
      ],
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
