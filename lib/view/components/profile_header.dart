import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userInfo;

  const ProfileHeader({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.purple.withOpacity(0.2),
          child: Icon(Icons.person, size: 60, color: Colors.purple.shade200),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            userInfo['nickname'] ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            userInfo['userfullname'] ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ),
        if (userInfo['zodiac'] != null) ...[
          const SizedBox(height: 10),
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9575CD), Color(0xFF7E57C2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Burç: ${userInfo['zodiac']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 30),
      ],
    );
  }
}
