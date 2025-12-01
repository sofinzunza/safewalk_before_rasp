import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:safewalk/data/models/user_model.dart';
import 'package:safewalk/data/services/firestore_service.dart';

class TlocationPage extends StatefulWidget {
  const TlocationPage({super.key, this.lat, this.lng, this.userId});
  final double? lat;
  final double? lng;
  final String? userId; // UID del usuario a monitorear

  @override
  State<TlocationPage> createState() => _TlocationPageState();
}

class _TlocationPageState extends State<TlocationPage> {
  static const Color _primary = Color(0xFF2EB79B);

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<Map<String, dynamic>?>? _locationStreamSub;
  Timer? _timeoutTimer;

  LatLng? _currentLatLng;
  String _direccion = 'Obteniendo dirección…';
  bool _isLoading = true;
  String? _errorMessage;

  List<UserModel> _linkedUsers = [];
  UserModel? _selectedUser;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      // Si se proporcionaron coordenadas específicas
      if (widget.lat != null && widget.lng != null) {
        _updateLocation(LatLng(widget.lat!, widget.lng!));
        setState(() => _isLoading = false);
        return;
      }

      // Obtener el usuario actual
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
          _isLoading = false;
        });
        return;
      }

      // Obtener usuarios vinculados
      final linkedUsers = await firestoreService.getLinkedVisuallyImpaired(
        currentUserId,
      );

      if (linkedUsers.isEmpty) {
        setState(() {
          _errorMessage = 'No tienes usuarios vinculados para monitorear';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _linkedUsers = linkedUsers;
        _selectedUser = widget.userId != null
            ? linkedUsers.firstWhere(
                (u) => u.uid == widget.userId,
                orElse: () => linkedUsers.first,
              )
            : linkedUsers.first;
      });

      // Escuchar cambios de ubicación del usuario seleccionado
      _listenToUserLocation(_selectedUser!.uid);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al inicializar: $e';
        _isLoading = false;
      });
    }
  }

  void _listenToUserLocation(String userId) {
    _locationStreamSub?.cancel();
    _timeoutTimer?.cancel();

    // Timeout de 5 segundos para detectar si no hay datos
    bool hasReceivedData = false;

    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (!hasReceivedData && mounted && _isLoading) {
        setState(() {
          _errorMessage =
              'No se pudo cargar la ubicación.\n\n'
              'El usuario debe activar el botón SOS para compartir su ubicación.';
          _isLoading = false;
        });
      }
    });

    _locationStreamSub = firestoreService
        .watchUserLocation(userId)
        .listen(
          (locationData) {
            if (locationData == null || !mounted) return;

            final lat = locationData['lat'] as double?;
            final lng = locationData['lng'] as double?;
            final isActive = locationData['isActive'] as bool? ?? false;

            if (lat != null && lng != null && isActive) {
              // Solo mostrar ubicación si SOS está activo
              hasReceivedData = true;
              _timeoutTimer?.cancel();
              _updateLocation(LatLng(lat, lng));
              if (!mounted) return;
              setState(() {
                _isLoading = false;
                _errorMessage = null;
              });
            } else if (lat != null && lng != null && !isActive) {
              // Tiene ubicación pero SOS desactivado
              hasReceivedData = true;
              _timeoutTimer?.cancel();
              if (!mounted) return;
              setState(() {
                _errorMessage =
                    'El usuario no ha activado el SOS.\n\n'
                    'La ubicación solo se comparte cuando el botón SOS está activo.';
                _isLoading = false;
              });
            } else if (!hasReceivedData) {
              // Si los datos son null en la primera carga, esperamos el timeout
              // No marcamos hasReceivedData para que el timeout se active
            }
          },
          onError: (error) {
            _timeoutTimer?.cancel();
            if (!mounted) return;
            setState(() {
              _errorMessage = 'Error al cargar ubicación: $error';
              _isLoading = false;
            });
          },
        );
  }

  void _switchUser(UserModel user) {
    setState(() {
      _selectedUser = user;
      _isLoading = true;
      _markers.clear();
    });
    _listenToUserLocation(user.uid);
  }

  Future<void> _updateLocation(LatLng latLng) async {
    if (!mounted) return;

    final marker = Marker(
      markerId: const MarkerId('ciego'),
      position: latLng,
      infoWindow: const InfoWindow(title: 'Ubicación del usuario'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    if (!mounted) return;
    setState(() {
      _currentLatLng = latLng;
      _markers
        ..clear()
        ..add(marker);
    });

    // Pequeño delay para que el mapa se reconstruya con el nuevo key
    await Future.delayed(const Duration(milliseconds: 100));

    if (_mapController != null && mounted) {
      try {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 16),
          ),
        );
      } catch (e) {
        // Ignorar errores si el controlador ya fue disposed
      }
    }
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[];
        if ((p.street ?? '').isNotEmpty) parts.add(p.street!);
        if ((p.subLocality ?? '').isNotEmpty) parts.add(p.subLocality!);
        if ((p.locality ?? '').isNotEmpty) parts.add(p.locality!);
        if ((p.administrativeArea ?? '').isNotEmpty) {
          parts.add(p.administrativeArea!);
        }
        setState(() {
          _direccion = parts.isEmpty
              ? 'Dirección no disponible'
              : parts.join(', ');
        });
      }
    // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _positionSub?.cancel();
    _locationStreamSub?.cancel();
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final double collapsedHeight = media.width * 0.68;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Ubicación en Tiempo Real',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            if (_selectedUser != null)
              Text(
                _selectedUser!.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        actions: [
          if (_linkedUsers.length > 1)
            PopupMenuButton<UserModel>(
              icon: const Icon(Icons.people),
              tooltip: 'Cambiar usuario',
              onSelected: _switchUser,
              itemBuilder: (context) {
                return _linkedUsers.map((user) {
                  return PopupMenuItem<UserModel>(
                    value: user,
                    child: Row(
                      children: [
                        Icon(
                          user.uid == _selectedUser?.uid
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 20,
                          color: user.uid == _selectedUser?.uid
                              ? _primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(user.name),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando ubicación...'),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _initLocation();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: collapsedHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade200,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        GoogleMap(
                          key: ValueKey(_currentLatLng),
                          initialCameraPosition: CameraPosition(
                            target:
                                _currentLatLng ??
                                const LatLng(-33.447487, -70.673676),
                            zoom: 16,
                          ),
                          onMapCreated: (c) async {
                            if (!mounted) return;
                            _mapController = c;
                          },
                          markers: _markers,
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          compassEnabled: true,
                          mapType: MapType.normal,
                          liteModeEnabled: false,
                          // Tap → pantalla completa
                          onTap: (position) async {
                            await Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: true,
                                barrierColor: Colors.black,
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        _FullscreenMapPage(
                                          currentLatLng: _currentLatLng,
                                          markers: _markers,
                                        ),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) => FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                              ),
                            );
                          },
                        ),
                        // Botón "centrar"
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Material(
                            color: Colors.white,
                            elevation: 2,
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(Icons.my_location),
                              onPressed: () {
                                if (_currentLatLng != null &&
                                    _mapController != null) {
                                  _mapController!.animateCamera(
                                    CameraUpdate.newLatLng(_currentLatLng!),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dirección justo debajo del mapa
                  const SizedBox(height: 10),
                  const Text(
                    'Dirección:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _direccion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}

/// Página de mapa a pantalla completa
class _FullscreenMapPage extends StatefulWidget {
  const _FullscreenMapPage({
    required this.currentLatLng,
    required this.markers,
  });

  final LatLng? currentLatLng;
  final Set<Marker> markers;

  @override
  State<_FullscreenMapPage> createState() => _FullscreenMapPageState();
}

class _FullscreenMapPageState extends State<_FullscreenMapPage> {
  GoogleMapController? _controller;
  StreamSubscription<Position>? _sub;

  final LatLng _fallback = const LatLng(-33.447487, -70.673676); // Santiago
  LatLng? _liveLatLng;
  late final Set<Marker> _markers = Set<Marker>.from(widget.markers);

  @override
  void initState() {
    super.initState();
    _liveLatLng = widget.currentLatLng;
    _listenLocation();
  }

  void _listenLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) return;

      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      );
      _sub = Geolocator.getPositionStream(locationSettings: settings).listen((
        pos,
      ) {
        if (!mounted) return;
        final here = LatLng(pos.latitude, pos.longitude);
        setState(() => _liveLatLng = here);
        _controller?.animateCamera(CameraUpdate.newLatLng(here));
      });
    // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initial = _liveLatLng ?? widget.currentLatLng ?? _fallback;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: initial, zoom: 16),
            onMapCreated: (c) => _controller = c,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),
          // Cerrar (arriba-izquierda)
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: Material(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.35),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cerrar',
                ),
              ),
            ),
          ),
          // Centrar en mí (abajo-derecha)
          Positioned(
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: Material(
                color: Colors.white,
                elevation: 3,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () {
                    final target =
                        _liveLatLng ?? widget.currentLatLng ?? _fallback;
                    _controller?.animateCamera(CameraUpdate.newLatLng(target));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
