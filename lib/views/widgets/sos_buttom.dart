import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'signal_painter.dart';

class SosButtom extends StatefulWidget {
  const SosButtom({super.key});

  @override
  State<SosButtom> createState() => _SosButtomState();
}

class _SosButtomState extends State<SosButtom>
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
        content: Text(
          _pressed ? 'Activando emergencia...' : 'Emergencia cancelada',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const size = 260.0;

    return Semantics(
      button: true,
      hint:
          'Presiona para activar la emergencia, presiona de nuevo para cancelar',
      onTapHint: 'Iniciando llamada de emergencia',
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) => CustomPaint(
              painter: SignalPainter(
                progress: _pulse.value,
                color: KColors.naranjo,
              ),
              child: const SizedBox(width: size, height: size),
            ),
          ),
          ElevatedButton(
            onPressed: _onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(50),
              backgroundColor: Colors.red[400],
              elevation: 10,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 110,
            ),
          ),
        ],
      ),
    );
  }
}
