import 'package:flutter/material.dart';

/// Sohbet rehberlik mesajını gösteren bileşen
/// Boş sohbet listesi veya seçili sohbet olmadığında gösterilir
class GuidanceMessage extends StatelessWidget {
  final String message;

  const GuidanceMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
