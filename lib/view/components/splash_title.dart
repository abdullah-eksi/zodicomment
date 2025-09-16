import 'package:flutter/material.dart';

/// Splash sayfasında gösterilen başlık ve açıklama widget'ı.
///
/// Uygulama başlığı ve açıklaması stilize edilmiş şekilde gösterilir.
class SplashTitle extends StatelessWidget {
  final String title;
  final String description;

  const SplashTitle({Key? key, required this.title, required this.description})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 17),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
