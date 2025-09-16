import 'package:flutter/material.dart';

/// Splash sayfasında gösterilen maskot widget'ı.
///
/// Yumuşak gölge ve beyaz arka planla çerçevelenmiş maskot görselini içerir.
class SplashMascot extends StatelessWidget {
  final double size;

  const SplashMascot({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Image.asset(
        'assets/images/maskot.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
