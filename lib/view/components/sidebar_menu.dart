import 'package:flutter/material.dart';

class SidebarMenu extends StatelessWidget {
  final List<Map<String, dynamic>> chatHistory;
  final VoidCallback onNewChat;
  final ValueChanged<Map<String, dynamic>> onSelectChat;
  final VoidCallback onClose;
  final VoidCallback onProfileTap;
  const SidebarMenu({
    required this.chatHistory,
    required this.onNewChat,
    required this.onSelectChat,
    required this.onClose,
    required this.onProfileTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF181A2A),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sohbetler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Kapat',
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),

          // New Chat Button
          _buildMenuItem(
            icon: Icons.add_comment,
            label: 'Yeni Sohbet',
            onTap: onNewChat,
            isActive: false,
          ),

          const SizedBox(height: 8),
          const Divider(color: Colors.white24, height: 1),

          // Chat History
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final chat = chatHistory[index];
                final isActive = chat['isActive'] == true;

                return _buildMenuItem(
                  icon: isActive ? Icons.chat : Icons.chat_bubble_outline,
                  label: chat['title'] as String,
                  onTap: () => onSelectChat(chat),
                  isActive: isActive,
                );
              },
            ),
          ),

          // Profile section at the bottom
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.person,
            label: 'Profil',
            onTap: onProfileTap,
            isActive: false,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5E35B1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? const Border(
                  left: BorderSide(color: Colors.deepPurpleAccent, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white60,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
