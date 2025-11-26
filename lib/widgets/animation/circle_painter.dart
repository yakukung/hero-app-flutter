import 'package:flutter/material.dart';
import 'dart:math' as math;

class CirclePainter extends CustomPainter {
  final int circleCount;
  final Color color;
  final double initialRadius;
  final double radiusStep;
  final double strokeWidth;
  final Animation<double> animation;

  CirclePainter({
    this.circleCount = 7,
    this.color = Colors.white,
    this.initialRadius = 80.0,
    this.radiusStep = 30.0,
    this.strokeWidth = 2.5,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height * 0.44);

    for (int i = 0; i < circleCount; i++) {
      final radiusMultiplier =
          1 + (math.sin(animation.value * 2 * math.pi) * 0.05);
      final radius = (initialRadius + (i * radiusStep)) * radiusMultiplier;

      final opacity = 1.0 - (i / (circleCount * 1.5));
      paint.color = Color.fromARGB(
        (opacity.clamp(0.1, 1.0) * 255).round(),
        color.red,
        color.green,
        color.blue,
      );

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) {
    return oldDelegate.circleCount != circleCount ||
        oldDelegate.color != color ||
        oldDelegate.initialRadius != initialRadius ||
        oldDelegate.radiusStep != radiusStep ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.animation != animation;
  }
}
