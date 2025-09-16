import 'package:zodicomment/model/messageModel.dart';
import 'package:zodicomment/model/databaseModel.dart';

/// Sohbet işlemlerini yöneten servis sınıfı
class ChatService {
  /// Bir kullanıcının tüm sohbet geçmişini al
  static Future<List<Map<String, dynamic>>> getUserChatHistory(
    int userId,
  ) async {
    return await MessageModel.getUserChatsWithMode(userId);
  }

  /// Belirli bir sohbetin tüm mesajlarını al
  static Future<List<Map<String, dynamic>>> getChatMessages(int chatId) async {
    final chatMessages = await DatabaseModel.select(
      DatabaseModel.chatMessagesTable,
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'created_at ASC',
    );

    return chatMessages
        .map(
          (msg) => {
            'message': msg['message'],
            'is_user': msg['is_user'],
            'created_at': msg['created_at'],
          },
        )
        .toList();
  }

  /// Yeni bir sohbet oluştur
  static Future<int> createNewChat(int userId) async {
    return await MessageModel.createNewChat(userId: userId);
  }

  /// Kullanıcı mesajı gönder ve AI yanıtı al
  static Future<Map<String, dynamic>> sendMessageAndGetAIResponse({
    required int chatId,
    required int userId,
    required String message,
    required String userMode,
  }) async {
    // Kullanıcı mesajını ekle
    await MessageModel.addMessage(
      chatId: chatId,
      userId: userId,
      message: message,
      isUser: true,
    );

    // Eğer ilk mesaj ise, sohbetin başlığını güncelle
    final chatMessages = await DatabaseModel.select(
      DatabaseModel.chatMessagesTable,
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );

    bool isFirstMessage = chatMessages.length == 1;
    if (isFirstMessage) {
      final title = MessageModel.generateTitleFromMessage(message);
      await MessageModel.updateChatTitle(chatId: chatId, newTitle: title);
    }

    // AI yanıtını al ve kaydet
    final aiResponse = await MessageModel.generateAndSaveAIComment(
      userId: userId,
      type: 'sohbet',
      input: message,
      userMode: userMode,
      chatId: chatId,
    );

    // AI mesajını veritabanına ekle
    await MessageModel.addMessage(
      chatId: chatId,
      userId: userId,
      message: aiResponse,
      isUser: false,
    );

    return {'aiResponse': aiResponse, 'isFirstMessage': isFirstMessage};
  }

  /// Sohbet geçmişini sil
  static Future<void> deleteAllChatHistory(int userId) async {
    await MessageModel.deleteAllUserChats(userId);
  }

  /// Belirli bir sohbeti sil
  static Future<void> deleteChat(int chatId) async {
    // İlgili sohbetteki tüm mesajları sil
    await DatabaseModel.delete(
      DatabaseModel.chatMessagesTable,
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );

    // Sohbeti sil
    await DatabaseModel.delete(
      DatabaseModel.chatsTable,
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }
}
