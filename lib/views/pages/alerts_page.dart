import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/alert_utils.dart';
import 'package:safewalk/data/notifiers.dart';
import 'package:safewalk/views/pages/salerts_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  static const _kPeople = 'alert_people';
  static const _kStairs = 'alert_stairs';
  static const _kCars = 'alert_cars';
  static const _kMotorcycles = 'alert_motorcycles';
  static const _kBikes = 'alert_bikes';
  static const _kDogs = 'alert_dogs';
  static const _kTree = 'alert_tree';
  static const _kDoor = 'alert_door';
  static const _kEscalator = 'alert_escalator';

  // ---- Estado ----
  bool aPeople = true;
  bool aStairs = false;
  bool aCars = true;
  bool aMotorcycles = false;
  bool aBikes = false;
  bool aDogs = true;
  bool aTree = false;
  bool aDoor = true;
  bool aEscalator = false;
  bool aCrosswalkState = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    alertStateNotifier.addListener(_onAlertStateChanged);
    crosswalkAlertsNotifier.addListener(_onCrosswalkAlertsChanged);
  }

  @override
  void dispose() {
    alertStateNotifier.removeListener(_onAlertStateChanged);
    crosswalkAlertsNotifier.removeListener(_onCrosswalkAlertsChanged);
    super.dispose();
  }

  void _onAlertStateChanged() async {
    await SharedPreferences.getInstance();
  }

  void _onCrosswalkAlertsChanged() {
    if (mounted) {
      setState(() {
        aCrosswalkState = crosswalkAlertsNotifier.value;
      });
    }
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();

    final crosswalkState = await AlertUtils.getCrosswalkAlertState();

    setState(() {
      aPeople = p.getBool(_kPeople) ?? aPeople;
      aStairs = p.getBool(_kStairs) ?? aStairs;
      aCars = p.getBool(_kCars) ?? aCars;
      aMotorcycles = p.getBool(_kMotorcycles) ?? aMotorcycles;
      aBikes = p.getBool(_kBikes) ?? aBikes;
      aDogs = p.getBool(_kDogs) ?? aDogs;
      aTree = p.getBool(_kTree) ?? aTree;
      aDoor = p.getBool(_kDoor) ?? aDoor;
      aEscalator = p.getBool(_kEscalator) ?? aEscalator;
      aCrosswalkState = crosswalkState;
    });
  }

  Future<void> _saveBool(String k, bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(k, v);
    await AlertUtils.notifyConfigurationChanged();
  }

  // ✅ NUEVO: Notificar cambios a home_page para actualizar BLE
  void _notifyConfigurationUpdate() {
    // Disparar actualización global de configuración
    AlertUtils.notifyConfigurationChanged();
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
                'Configuración\nde Alertas',
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
                  _SwitchTile(
                    icon: Icons.traffic,
                    title: 'Alertas de Estado de Semáforo Peatonal',
                    value: aCrosswalkState,
                    activeColor: active,
                    onChanged: (v) async {
                      setState(() => aCrosswalkState = v);
                      await AlertUtils.setCrosswalkAlertState(v);
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
                    onChanged: (v) async {
                      setState(() => aPeople = v);
                      await _saveBool(_kPeople, v);
                      _notifyConfigurationUpdate();
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.stairs,
                    title: 'Alertas de Escaleras',
                    value: aStairs,
                    activeColor: active,
                    onChanged: (v) async {
                      setState(() => aStairs = v);
                      await _saveBool(_kStairs, v);
                      _notifyConfigurationUpdate();
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.directions_car,
                    title: 'Alertas de Autos',
                    value: aCars,
                    activeColor: active,
                    onChanged: (v) async {
                      setState(() => aCars = v);
                      await _saveBool(_kCars, v);
                      _notifyConfigurationUpdate();
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.motorcycle_rounded,
                    title: 'Alertas de Motos',
                    value: aMotorcycles,
                    activeColor: active,
                    onChanged: (v) async {
                      setState(() => aMotorcycles = v);
                      await _saveBool(_kMotorcycles, v);
                      _notifyConfigurationUpdate();
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.pedal_bike_rounded,
                    title: 'Alertas de Bicicletas',
                    value: aBikes,
                    activeColor: active,
                    onChanged: (v) async {
                      setState(() => aBikes = v);
                      await _saveBool(_kBikes, v);
                      _notifyConfigurationUpdate();
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.pets,
                    title: 'Alertas de Perros',
                    value: aDogs,
                    activeColor: active,
                    onChanged: (v) async {
                      setState(() => aDogs = v);
                      await _saveBool(_kDogs, v);
                      _notifyConfigurationUpdate();
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.park,
                    title: 'Alertas de Árbol',
                    value: aTree,
                    activeColor: active,
                    onChanged: (v) async {
                      setState(() => aTree = v);
                      await _saveBool(_kTree, v);
                      _notifyConfigurationUpdate();
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.door_sliding,
                    title: 'Alertas de Puertas',
                    value: aDoor,
                    activeColor: active,
                    onChanged: (v) async {
                      setState(() => aDoor = v);
                      await _saveBool(_kDoor, v);
                      _notifyConfigurationUpdate();
                    },
                  ),
                  _SwitchTile(
                    icon: Icons.escalator,
                    title: 'Alertas de Escaleras Mecánicas',
                    value: aEscalator,
                    activeColor: active,
                    onChanged: (v) async {
                      setState(() => aEscalator = v);
                      await _saveBool(_kEscalator, v);
                      _notifyConfigurationUpdate();
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Configuración Avanzada de Alertas'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SettingsAlertsPage();
                    },
                  ),
                );
              },
            ),
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
    return Semantics(
      header: true,
      label: text,
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
