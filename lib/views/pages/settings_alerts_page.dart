import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/alert_utils.dart';
import 'package:safewalk/data/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsAlertsPage extends StatefulWidget {
  const SettingsAlertsPage({super.key});

  @override
  State<SettingsAlertsPage> createState() => _SettingsAlertsPageState();
}

class _SettingsAlertsPageState extends State<SettingsAlertsPage> {
  // ---- Preferencias (claves) ----
  static const _kVibration = KContanse.vibrationKey;
  static const _kVibrationIntensity = KContanse.vibrationIntensityKey;
  static const _kSound = KContanse.soundKey;
  static const _kVolumeIntensity = KContanse.volumeIntensityKey;

  static const _kMinDistance = 'min_distance'; // metros mínimos
  static const _kMaxDistance = 'max_distance'; // metros máximos

  // ---- Estado ----
  bool vibration = false;
  double vibrationIntensity = 50;
  bool sound = true;
  double volumeIntensity = 50;

  double minDistance = 1.0;
  double maxDistance = 5.0;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    alertStateNotifier.addListener(_onAlertStateChanged);
  }

  @override
  void dispose() {
    alertStateNotifier.removeListener(_onAlertStateChanged);
    super.dispose();
  }

  void _onAlertStateChanged() async {
    final prefs = await SharedPreferences.getInstance();
    final newVibration = prefs.getBool(KContanse.vibrationKey) ?? false;
    final newSound = prefs.getBool(KContanse.soundKey) ?? true;

    if (mounted) {
      setState(() {
        vibration = newVibration;
        sound = newSound;
      });
    }
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();

    setState(() {
      vibration = p.getBool(_kVibration) ?? vibration;
      vibrationIntensity =
          p.getDouble(_kVibrationIntensity) ?? vibrationIntensity;
      sound = p.getBool(_kSound) ?? sound;
      volumeIntensity = p.getDouble(_kVolumeIntensity) ?? volumeIntensity;

      minDistance = p.getDouble(_kMinDistance) ?? minDistance;
      maxDistance = p.getDouble(_kMaxDistance) ?? maxDistance;

      if (minDistance < 1.0) minDistance = 1.0;
      if (minDistance > 3.0) minDistance = 3.0;
      if (maxDistance < 1.0) maxDistance = 1.0;
      if (maxDistance > 8.0) maxDistance = 8.0;
      if (minDistance >= maxDistance) {
        minDistance = 1.0;
        maxDistance = 5.0;
      }
    });
  }

  Future<void> _saveBool(String k, bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(k, v);
    await AlertUtils.notifyConfigurationChanged();
  }

  Future<void> _saveDouble(String k, double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(k, v);
    await AlertUtils.notifyConfigurationChanged();
  }

  @override
  Widget build(BuildContext context) {
    final active = KColors.tealChillon; // color del switch/slider

    return Scaffold(
      backgroundColor: KColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
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
                ),
                const SizedBox(width: 48), // Para balancear el IconButton
              ],
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
                    onChanged: (v) async {
                      setState(() => vibration = v);
                      await _saveBool(_kVibration, v);
                      // Actualizar el estado global de alertas
                      final newAlertState = await AlertUtils.getAlertState();
                      alertStateNotifier.value = newAlertState;
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
                    onChanged: (v) async {
                      setState(() => sound = v);
                      await _saveBool(_kSound, v);
                      // Actualizar el estado global de alertas
                      final newAlertState = await AlertUtils.getAlertState();
                      alertStateNotifier.value = newAlertState;
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
                  _SectionTitle(
                    'Configura a qué distancia quieres recibir alertas:',
                  ),
                  const SizedBox(height: 8),

                  // Descripción explicativa
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  // ⭐ Slider para distancia mínima (1.0m - 3.0m)
                  _DistanceSlider(
                    label: 'Distancia mínima de alerta:',
                    value: minDistance,
                    min: 1.0,
                    max: 3.0,
                    divisions: 4,
                    unit: 'm',
                    description:
                        'A partir de esta distancia comenzarás a recibir alertas',
                    minIcon: Icons.warning_amber_rounded,
                    maxIcon: Icons.warning_rounded,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() {
                        minDistance = v;
                        if (minDistance >= maxDistance) {
                          maxDistance = minDistance + 1.0;
                          if (maxDistance > 8.0) maxDistance = 8.0;
                        }
                      });
                      _saveDouble(_kMinDistance, v);
                      if (minDistance >= maxDistance) {
                        _saveDouble(_kMaxDistance, maxDistance);
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  // ⭐ Slider para distancia máxima (1.0m - 8.0m)
                  _DistanceSlider(
                    label: 'Distancia máxima de alerta:',
                    value: maxDistance,
                    min: 1.0,
                    max: 8.0,
                    divisions: 7,
                    unit: 'm',
                    description:
                        'Hasta esta distancia recibirás alertas de obstáculos',
                    minIcon: Icons.new_releases_outlined,
                    maxIcon: Icons.new_releases_rounded,
                    activeColor: active,
                    onChanged: (v) {
                      setState(() {
                        maxDistance = v;
                        if (maxDistance <= minDistance) {
                          minDistance = maxDistance - 1.0;
                          if (minDistance < 1.0) minDistance = 1.0;
                        }
                      });
                      _saveDouble(_kMaxDistance, v);
                      if (maxDistance <= minDistance) {
                        _saveDouble(_kMinDistance, minDistance);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Resumen visual del rango
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: KColors.tealOscuro,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rango de alertas: ${minDistance.toStringAsFixed(1)}m - ${maxDistance.toStringAsFixed(1)}m',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: KColors.tealOscuro,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ---------- Widgets ----------

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

class _DistanceSlider extends StatelessWidget {
  const _DistanceSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.description,
    required this.minIcon,
    required this.maxIcon,
    required this.activeColor,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final String description;
  final IconData minIcon;
  final IconData maxIcon;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(minIcon, size: 22, color: KColors.tealOscuro),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: activeColor,
                  thumbColor: activeColor,
                  trackHeight: 4,
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: '${value.toStringAsFixed(1)}$unit',
                  onChanged: onChanged,
                ),
              ),
            ),
            Icon(maxIcon, size: 22, color: KColors.tealOscuro),
          ],
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: activeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${value.toStringAsFixed(1)} $unit',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: activeColor,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
