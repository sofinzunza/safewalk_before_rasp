import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'signal_painter.dart';

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

  bool _pressed = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPressed() {
    setState(() => _pressed = !_pressed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_pressed ? 'Bucando Gorro NaviCap...' : 'Desconectado'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const size = 260.0;

    return Semantics(
      button: true,
      label: 'Conectar Bluetooth',
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => CustomPaint(
              painter: SignalPainter(progress: _pulse.value, color: KColors.bt),
              child: const SizedBox(width: size, height: size),
            ),
          ),
          ElevatedButton(
            onPressed: _onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(50),
              backgroundColor: KColors.bt,
              elevation: 10,
            ),
            child: const Icon(
              Icons.bluetooth,
              color: Colors.white,
              size: 120,
              semanticLabel: 'hola sofia',
            ),
          ),
        ],
      ),
    );
  }
}
