import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:safewalk/data/services/firestore_service.dart';
import 'package:safewalk/data/services/notification_service.dart';
import 'tlocation_page.dart';
import 'settings_page.dart';

class TwelcomePage extends StatefulWidget {
  const TwelcomePage({super.key, this.nombre});
  final String? nombre;

  @override
  State<TwelcomePage> createState() => _TwelcomePageState();
}

class _TwelcomePageState extends State<TwelcomePage> {
  static const Color _primary = Color(0xFF2EB79B);

  static const String _kDarkMode = 'prefs_dark_mode';
  static const String _kSosCalls = 'prefs_sos_calls_enabled';
  static const String _kSosMsgs = 'prefs_sos_msgs_enabled';

  bool _isDark = false;
  bool _receiveSosCalls = true;
  bool _receiveSosMsgs = true;

  int _currentPage = 0; // 0=Home, 1=Mapa, 2=Config

  // StreamSubscription para cancelarlo en dispose
  StreamSubscription<List<Map<String, dynamic>>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _setupNotificationListener();
  }

  @override
  void dispose() {
    // Cancelar la suscripción al stream para evitar memory leaks
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // Escuchar notificaciones en tiempo real
    _notificationSubscription = firestoreService
        .watchNotifications(currentUserId)
        .listen((notifications) {
          if (!mounted) return;

          // Mostrar cada notificación nueva
          for (final notification in notifications) {
            if (notification['type'] == 'emergency_alert') {
              // Mostrar notificación local
              notificationService.showEmergencyNotification(
                userName: notification['userName'] ?? 'Un usuario',
                userId: notification['userId'] ?? '',
              );

              // Mostrar diálogo en la app
              _showEmergencyDialog(notification);

              // Marcar como leída
              firestoreService.markNotificationAsRead(
                currentUserId,
                notification['id'],
              );
            }
          }
        });
  }

  void _showEmergencyDialog(Map<String, dynamic> notification) {
    final userName = notification['userName'] ?? 'Un usuario';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '🚨 ALERTA SOS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡$userName necesita ayuda!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ve la ubicación en tiempo real',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar a la página de ubicación
              setState(() => _currentPage = 1);
              // Si necesitas pasar el userId específico:
              // Puedes crear una nueva página o modificar TlocationPage
            },
            icon: const Icon(Icons.map),
            label: const Text('Ver ubicación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = prefs.getBool(_kDarkMode) ?? false;
      _receiveSosCalls = prefs.getBool(_kSosCalls) ?? true;
      _receiveSosMsgs = prefs.getBool(_kSosMsgs) ?? true;
    });
  }

  Future<void> _saveDark(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_kDarkMode, v);
  Future<void> _saveCalls(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_kSosCalls, v);
  Future<void> _saveMsgs(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_kSosMsgs, v);

  void _onItemTapped(int index) {
    if (index == _currentPage) return;
    setState(() => _currentPage = index);
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _buildHomePage();
      case 1:
        return const TlocationPage();
      case 2:
        return const SettingsPage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    final String saludo =
        'Bienvenido${widget.nombre != null && widget.nombre!.trim().isNotEmpty ? ', ${widget.nombre!.trim()}' : ''}';

    final Color text = _isDark ? Colors.white : Colors.black87;

    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      saludo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 86,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Image.asset(
                        'assets/images/2.png',
                        width: 380,
                        height: 380,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person_pin_circle,
                          size: 160,
                          color: _primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        'Recibir llamadas SOS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: text,
                        ),
                      ),
                      secondary: Icon(Icons.call, color: text),
                      activeTrackColor: _primary,
                      value: _receiveSosCalls,
                      onChanged: (v) {
                        setState(() => _receiveSosCalls = v);
                        _saveCalls(v);
                      },
                    ),
                    Divider(
                      height: 1,
                      color: _isDark ? Colors.white12 : Colors.black12,
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        'Recibir mensajes de SOS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: text,
                        ),
                      ),
                      secondary: Icon(Icons.sms, color: text),
                      activeTrackColor: _primary,
                      value: _receiveSosMsgs,
                      onChanged: (v) {
                        setState(() => _receiveSosMsgs = v);
                        _saveMsgs(v);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            tooltip: _isDark ? 'Modo claro' : 'Modo oscuro',
            icon: Icon(
              _isDark ? Icons.light_mode : Icons.nightlight_round,
              color: _isDark ? Colors.white : Colors.black,
              size: 26,
            ),
            onPressed: () {
              setState(() => _isDark = !_isDark);
              _saveDark(_isDark);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = _isDark ? const Color(0xFF121212) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: _buildCurrentPage()),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(icon: Icon(Icons.map_rounded), label: 'Mapa'),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Configuración',
          ),
        ],
        onDestinationSelected: _onItemTapped,
        selectedIndex: _currentPage,
      ),
    );
  }
}
