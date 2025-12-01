import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/data/services/ble_service.dart';
import 'signal_painter.dart';
import 'dart:async';

class BleButton extends StatefulWidget {
  const BleButton({super.key});

  @override
  State<BleButton> createState() => _BleButtonState();
}

class _BleButtonState extends State<BleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final Animation<double> _pulse = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );

  late BleService _bleService;
  StreamSubscription? _connectionSubscription;
  int _connectionState = BleService.connectionStateDisconnected;
  String _statusMessage = 'Desconectado';

  @override
  void initState() {
    super.initState();
    _initBleService();
  }

  Future<void> _initBleService() async {
    _bleService = BleService();
    await _bleService.initialize();

    _connectionSubscription = _bleService.connectionStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _connectionState = state;
        _statusMessage = _bleService.statusMessage;
      });
    });
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _bleService.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    try {
      await _bleService.toggleConnection();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  IconData _getIcon() {
    switch (_connectionState) {
      case BleService.connectionStateConnected:
        return Icons.bluetooth_connected;
      case BleService.connectionStateSearching:
        return Icons.bluetooth_searching;
      default:
        return Icons.bluetooth;
    }
  }

  Color _getColor() {
    switch (_connectionState) {
      case BleService.connectionStateConnected:
        return Colors.green;
      case BleService.connectionStateSearching:
        return Colors.orange;
      default:
        return KColors.bt;
    }
  }

  String _getStateDescription() {
    switch (_connectionState) {
      case BleService.connectionStateConnected:
        return 'Conectado';
      case BleService.connectionStateSearching:
        return 'Buscando';
      default:
        return 'Desconectado';
    }
  }

  String _getActionHint() {
    switch (_connectionState) {
      case BleService.connectionStateConnected:
        return 'Doble toque para desconectar';
      case BleService.connectionStateSearching:
        return 'Doble toque para cancelar búsqueda';
      default:
        return 'Doble toque para buscar y conectar';
    }
  }

  @override
  Widget build(BuildContext context) {
    const size = 260.0;
    final isSearching = _connectionState == BleService.connectionStateSearching;
    final stateDescription = _getStateDescription();
    final String semanticLabel =
        'Bluetooth: $stateDescription. $_statusMessage';

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: _getActionHint(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isSearching)
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) => CustomPaint(
                    painter: SignalPainter(
                      progress: _pulse.value,
                      color: _getColor(),
                    ),
                    child: const SizedBox(width: size, height: size),
                  ),
                ),
              ElevatedButton(
                onPressed: _onPressed,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(50),
                  backgroundColor: _getColor(),
                  elevation: 10,
                ),
                child: Icon(
                  _getIcon(),
                  color: Colors.white,
                  size: 120,
                  semanticLabel: stateDescription,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getColor(),
            ),
          ),
        ],
      ),
    );
  }
}
