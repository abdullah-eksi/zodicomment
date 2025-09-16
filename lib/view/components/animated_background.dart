import 'package:flutter/material.dart';

/// Animasyonlu yıldız arkaplanı bileşeni
/// Login ve Register sayfalarında ortak kullanılır
class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A2E), 
            Color(0xFF16213E), 
            Color(0xFF0F3460), 
          ],
        ),
      ),
      child: Stack(
        children: [
       
          // İçerik
          widget.child,
        ],
      ),
    );
  }
}
