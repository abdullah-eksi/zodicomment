import 'package:flutter/material.dart';
import 'dart:math' as math;

class ThinkingMaskot extends StatefulWidget {
  const ThinkingMaskot({super.key});

  @override
  State<ThinkingMaskot> createState() => _ThinkingMaskotState();
}

class _ThinkingMaskotState extends State<ThinkingMaskot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: child,
            );
          },
          child: Image.asset('assets/images/maskot.png', height: 60, width: 60),
        ),
        const SizedBox(height: 8),
        const Text(
          'Zodi düşünüyor...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
