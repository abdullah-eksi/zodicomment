import 'package:flutter/material.dart';
import 'package:zodicomment/routes.dart';
import 'package:zodicomment/model/userModel.dart';

class ProfileActions extends StatelessWidget {
  final Map<String, dynamic> userInfo;
  final VoidCallback onDeleteChats;

  const ProfileActions({
    super.key,
    required this.userInfo,
    required this.onDeleteChats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sohbet Geçmişini Silme Butonu
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            onPressed: onDeleteChats,
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text(
              'Sohbet Geçmişini Sil',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE67E22),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 20),
        // Çıkış Yapma Butonu
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            onPressed: () async {
              await UserModel.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
