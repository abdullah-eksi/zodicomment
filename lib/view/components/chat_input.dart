import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isDisabled;
  final bool noActiveChat; // No active chat selected or no chats exist

  const ChatInput({
    required this.controller,
    required this.onSend,
    this.isDisabled = false,
    this.noActiveChat = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isDisabled,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: isDisabled
                    ? 'Yanıt bekleniyor...'
                    : noActiveChat
                    ? 'Önce bir sohbet seçin...'
                    : 'Mesajınızı yazın...',
                hintStyle: TextStyle(
                  color: isDisabled || noActiveChat
                      ? Colors.white30
                      : Colors.white54,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              noActiveChat ? Icons.chat_bubble_outline : Icons.send,
              color: noActiveChat || isDisabled
                  ? Colors.grey
                  : Colors.purpleAccent,
            ),
            onPressed: isDisabled || noActiveChat ? null : onSend,
            tooltip: noActiveChat
                ? 'Önce bir sohbet seçin veya yeni bir sohbet başlatın'
                : 'Gönder',
          ),
        ],
      ),
    );
  }
}
