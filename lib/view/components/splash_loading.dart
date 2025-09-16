import 'package:flutter/material.dart';

class SplashLoading extends StatelessWidget {
  final String message;
  final Color? color;

  const SplashLoading({Key? key, required this.message, this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final valueColor = color ?? Colors.white;

    return Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(valueColor),
          strokeWidth: 3.0,
        ),
        const SizedBox(height: 24),
        Text(
          message,
          style: TextStyle(color: valueColor.withOpacity(0.7), fontSize: 15),
        ),
      ],
    );
  }
}
