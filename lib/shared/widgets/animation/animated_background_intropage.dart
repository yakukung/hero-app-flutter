import 'package:flutter/material.dart';
import 'circle_painter.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFFD4E1FF),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CustomPaint(
              painter: CirclePainter(
                color: Color.fromARGB(128, 255, 255, 255),
                initialRadius: 80,
                radiusStep: 90,
                circleCount: 7,
                strokeWidth: 4,
                animation: _controller,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 170.0),
              child: Image.asset(
                'assets/images/logo/hero-logo.png',
                width: 380,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
