import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/alert_utils.dart';
import 'package:safewalk/data/models/ble_config.dart';
import 'package:safewalk/data/services/ble_service.dart';
import 'package:safewalk/data/services/obstacle_alert_service.dart';
import 'package:safewalk/views/widgets/multistatebutton_widget.dart';
import 'package:safewalk/views/widgets/navbar_widget.dart';
import 'package:safewalk/views/auth_service.dart';
import 'package:safewalk/data/notifiers.dart';
import 'package:safewalk/views/pages/alerts_page.dart';
import 'package:safewalk/views/pages/emergency_page.dart';
import 'package:safewalk/views/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _kObstacles = 'alerts_obstacles';
  static const _kSemaforo = 'estado_semaforo';

  bool aObstaculos = true;
  bool eSemaforo = false;
  bool isBluetoothOn = true;
  bool isAlertsOn = true;
  int bluetoothState = 1; // 0=desconectado, 1=conectado, 2=buscando
  late BleService _bleService;
  late ObstacleAlertService _obstacleAlertService;
  bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _initializeBleServices(); 
  }
  @override
  void dispose() {
    // ✅ LIMPIAR servicios BLE
    if (_servicesInitialized) {
      _bleService.dispose();
      _obstacleAlertService.dispose();
    }
    super.dispose();
  }

  // ✅ NUEVA: Inicializar servicios BLE
  Future<void> _initializeBleServices() async {
    try {
      _bleService = BleService();
      _obstacleAlertService = ObstacleAlertService(_bleService);
      
      await _bleService.initialize();
      await _obstacleAlertService.initialize();
      
      _servicesInitialized = true;
      
      // Escuchar cambios de estado de conexión BLE REAL
      _bleService.connectionStateStream.listen((state) {
        if (mounted) {
          setState(() {
            bluetoothState = state;
          });
        }
      });
      
      developer.log('✅ Servicios BLE inicializados correctamente', name: 'HomePage');
      
    } catch (e) {
      developer.log('❌ Error inicializando servicios BLE: $e', name: 'HomePage');
      setState(() {
        bluetoothState = 0; // Estado desconectado
      });
    }
  }

  // ✅ NUEVA: Manejar cambios en configuración
  Future<void> _onConfigurationChanged() async {
    if (!_servicesInitialized) return;
    
    try {
      final prefs = await AlertUtils.getAllPreferences();
      final config = BleConfig.fromPreferences(prefs);
      await _obstacleAlertService.updateConfiguration(config);
      developer.log('📤 Configuración BLE actualizada', name: 'HomePage');
    } catch (e) {
      developer.log('❌ Error actualizando configuración BLE: $e', name: 'HomePage');
    }
  }
  
  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    final currentAlertState = await AlertUtils.getAlertState();
    setState(() {
      aObstaculos = p.getBool(_kObstacles) ?? aObstaculos;
      eSemaforo = p.getBool(_kSemaforo) ?? eSemaforo;
    });
    alertStateNotifier.value = currentAlertState;
  }

  Future<void> _saveBool(String k, bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(k, v);
    await _onConfigurationChanged();
  }

  Widget _buildBodyForIndex(int index) {
    final active = KColors.tealChillon;
    switch (index) {
      case 1:
        return const AlertsPage();
      case 2:
        return const EmergencyPage();
      case 3:
        return const SettingsPage();
      case 0:
      default:
        final user = authService.value.currentUser;
        final displayName = user?.displayName;
        final fallbackName = user?.email?.split('@').first ?? 'Usuario';
        final nameToShow = displayName ?? fallbackName;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bienvenido/a, $nameToShow',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: "DMSans",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: Image.asset(
                    'assets/images/gorro.png',
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MultiStateButton(
                      title: 'Bluetooth',
                      icons: [
                        'assets/images/btoff.png',
                        'assets/images/btconnected.png',
                        'assets/images/searching.png',
                      ],
                      labels: ['Desconectado', 'Conectado', 'Buscando'],
                      currentState: bluetoothState,
                      borderColor: Colors.black45,
                      onPressed: () async {
                        // ✅ USAR BLE real en lugar de simulado
                        if (_servicesInitialized) {
                          try {
                            await _bleService.toggleConnection();
                          } catch (e) {
                            developer.log('❌ Error toggling BLE: $e', name: 'HomePage');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error Bluetooth: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          // Fallback si los servicios no están listos
                          setState(() {
                            bluetoothState = (bluetoothState + 1) % 3;
                          });
                        }
                      },
                    ),
                    SizedBox(width: 40),
                    ValueListenableBuilder<int>(
                      valueListenable: alertStateNotifier,
                      builder: (context, alertState, child) {
                        return MultiStateButton(
                          title: 'Alertas',
                          icons: [
                            'assets/images/ambas.png',
                            'assets/images/sonido.png',
                            'assets/images/vibracion.png',
                            'assets/images/apagadas.png',
                          ],
                          labels: [
                            'Ambos',
                            'Sonido',
                            'Vibración',
                            'Desactivadas',
                          ],
                          currentState: alertState,
                          borderColor: Colors.black45,
                          onPressed: () async {
                            final newState = (alertState + 1) % 4;
                            await AlertUtils.setAlertState(newState);
                            alertStateNotifier.value = newState;
                            await _onConfigurationChanged();
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _Switch(
                  icon: Icons.warning_amber_rounded,
                  title: 'Alertas de Obstáculos',
                  value: aObstaculos,
                  activeColor: active,
                  onChanged: (v) {
                    setState(() => aObstaculos = v);
                    _saveBool(_kObstacles, v);
                  },
                ),
                _Switch(
                  icon: Icons.traffic_rounded,
                  title: 'Alertas de estado de semáforos peatonales',
                  value: eSemaforo,
                  activeColor: active,
                  onChanged: (v) {
                    setState(() => eSemaforo = v);
                    _saveBool(_kSemaforo, v);
                  },
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: ValueListenableBuilder<int>(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedIndex, child) {
          return _buildBodyForIndex(selectedIndex);
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            elevation: 2,
            child: Container(color: Colors.white, child: const NavbarWidget()),
          ),
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
