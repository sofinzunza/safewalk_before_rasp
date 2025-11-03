import 'package:flutter/material.dart';

class SignalPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;

  SignalPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide * 0.5;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // tres ondas que crecen con el progreso
    for (int i = 0; i < 3; i++) {
      final t = (progress + i * 0.25) % 1.0;
      final radius = maxRadius * (0.2 + 0.8 * t);
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: opacity * 0.6);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SignalPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
