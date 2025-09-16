import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final String? guidanceMessage;

  const ChatList({required this.messages, this.guidanceMessage, super.key});

  @override
  Widget build(BuildContext context) {
    // If there are no messages and a guidance message is provided, show it
    if (messages.isEmpty && guidanceMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.purple.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              guidanceMessage!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Builder(
              builder: (context) => ElevatedButton.icon(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Sohbet Başlat'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // messages listesini ters çevirmeye gerek yok, ListView.builder reverse:true ile
    // otomatik olarak tersten gösterecek
    return ListView.builder(
      reverse: true, // Eski mesajlar üstte, yeni mesajlar altta görünecek
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        // Listeyi tersten işliyoruz (en yeni mesajlar altta)
        final msg = messages[messages.length - 1 - i];
        final isUser = msg['is_user'] == 1;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? Colors.purpleAccent : Colors.white10,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Text(
              msg['message'] ?? '',
              style: TextStyle(
                color: isUser ? Colors.white : Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
