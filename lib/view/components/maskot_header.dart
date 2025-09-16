import 'package:flutter/material.dart';

class MaskotHeader extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  const MaskotHeader({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        CircleAvatar(
          radius: 38,
          backgroundColor: Colors.white10,
          backgroundImage: AssetImage(imagePath),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.purple, blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}
