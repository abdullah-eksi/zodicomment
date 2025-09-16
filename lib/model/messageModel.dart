import 'package:zodicomment/model/databaseModel.dart';
import 'package:zodicomment/service/gemini.dart';
import 'package:zodicomment/model/userModel.dart';

class MessageModel {
  final int? id;
  final int chatId;
  final int userId;
  final String message;
  final bool isUser;
  final DateTime createdAt;

  MessageModel({
    this.id,
    required this.chatId,
    required this.userId,
    required this.message,
    required this.isUser,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as int?,
      chatId: map['chat_id'] as int,
      userId: map['user_id'] as int,
      message: map['message'] as String,
      isUser: (map['is_user'] ?? 1) == 1,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'user_id': userId,
      'message': message,
      'is_user': isUser ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Future<List<Map<String, dynamic>>> getUserChatsWithMode(
    int userId,
  ) async {
    // Kullanıcının modunu çek
    final user = await UserModel.getUserById(userId);
    final userMode = user?['mode'] ?? 'normal';

    // Kullanıcının sohbetlerini çek
    final chats = await DatabaseModel.select(
      DatabaseModel.chatsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    List<Map<String, dynamic>> chatList = [];
    for (final chat in chats) {
      // İlk mesajı çek
      final messages = await DatabaseModel.select(
        DatabaseModel.chatMessagesTable,
        where: 'chat_id = ?',
        whereArgs: [chat['id']],
        orderBy: 'created_at ASC',
        limit: 1,
      );
      String firstMsg = messages.isNotEmpty ? messages.first['message'] : '';
      String summary = firstMsg.length > 30
          ? firstMsg.substring(0, 30) + '...'
          : firstMsg;
      chatList.add({
        'chatId': chat['id'],
        'title': chat['title'],
        'summary': summary,
        'mode': userMode,
      });
    }
    return chatList;
  }

  static Future<int> createNewChat({
    required int userId,
    String title = 'Yeni Sohbet',
  }) async {
    final now = DateTime.now();
    final data = {
      'user_id': userId,
      'title': title,
      'created_at': now.toIso8601String(),
    };
    return await DatabaseModel.insert(DatabaseModel.chatsTable, data);
  }

  // Sohbet başlığını günceller
  static Future<int> updateChatTitle({
    required int chatId,
    required String newTitle,
  }) async {
    return await DatabaseModel.update(
      DatabaseModel.chatsTable,
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  // İlk mesajdan başlık oluşturur
  static String generateTitleFromMessage(String message) {
    // Mesajdan başlık oluştur - en fazla 30 karakter
    if (message.isEmpty) return 'Yeni Sohbet';

    // Mesaj 30 karakterden kısaysa doğrudan kullan
    if (message.length <= 30) return message;

    // Mesaj 30 karakterden uzunsa, ilk 27 karakteri al ve ... ekle
    return message.substring(0, 27) + '...';
  }

  // Kullanıcının tüm sohbet geçmişini siler
  static Future<void> deleteAllUserChats(int userId) async {
    // Önce kullanıcının tüm sohbetlerini bul
    final userChats = await DatabaseModel.select(
      DatabaseModel.chatsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Tüm sohbetleri ve mesajları sil
    for (var chat in userChats) {
      final chatId = chat['id'];

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

  // Mesajı veritabanına ekler
  static Future<int> addMessage({
    required int chatId,
    required int userId,
    required String message,
    required bool isUser,
  }) async {
    final now = DateTime.now();
    final data = {
      'chat_id': chatId,
      'user_id': userId,
      'message': message,
      'is_user': isUser ? 1 : 0,
      'created_at': now.toIso8601String(),
    };
    return await DatabaseModel.insert(DatabaseModel.chatMessagesTable, data);
  }

  // AI yorumu oluşturur ve veritabanına ekler
  static Future<int> addAIComment({
    required int userId,
    required String type, // burc, ruya, fal
    required String input,
    required String aiResponse,
    bool isFavorite = false,
    bool isShared = false,
  }) async {
    final now = DateTime.now();
    final data = {
      'user_id': userId,
      'type': type,
      'input': input,
      'ai_response': aiResponse,
      'is_favorite': isFavorite ? 1 : 0,
      'is_shared': isShared ? 1 : 0,
      'created_at': now.toIso8601String(),
    };
    return await DatabaseModel.insert(DatabaseModel.commentsTable, data);
  }

  // Kullanıcı bilgilerini al
  static Future<Map<String, String>> _getUserInfo(int userId) async {
    // Veritabanından kullanıcı bilgilerini al
    final users = await DatabaseModel.select(
      DatabaseModel.usersTable,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (users.isEmpty) {
      return {
        'nickname': 'Misafir',
        'fullname': '',
        'zodiac': '',
        'type': 'Genel',
      };
    }

    final user = users.first;

    return {
      'nickname': user['nickname'] ?? 'Misafir',
      'fullname': user['userfullname'] ?? '',
      'zodiac': user['zodiac'] ?? '',
      'type': 'Genel',
    };
  }

  // Gemini AI ile yorum oluşturur ve veritabanına ekler
  static Future<String> generateAndSaveAIComment({
    required int userId,
    required String type, // burc, ruya, fal
    required String input,
    String? userMode, // UserModel'den alınan mode: eglenceli, mistik, vs.
    String? userZodiac, // Kullanıcının burcu
    int? chatId, // Sohbet ID'si (sohbet modunda kullanılır)
    bool isFavorite = false,
    bool isShared = false,
  }) async {
    String modeInstruction = '';
    if (userMode != null) {
      switch (userMode) {
        case 'eglenceli':
          modeInstruction = '\nCevap eğlenceli ve esprili bir tonda olsun.';
          break;
        case 'romantik':
          modeInstruction = '\nCevap duygusal ve romantik bir tonda olsun.';
          break;
        case 'bilge':
          modeInstruction = '\nCevap derin ve felsefi bir tonda olsun.';
          break;
        case 'elestirel':
          modeInstruction = '\nCevap analitik ve sorgulayıcı bir tonda olsun.';
          break;
        default:
          modeInstruction = '\nCevap normal tonda olsun.';
      }
    }

    // Burç bilgisini ekle
    if (userZodiac != null && userZodiac.isNotEmpty) {
      modeInstruction +=
          '\nKullanıcının burcu: $userZodiac. Bu bilgiyi yanıtlarında kullanabilirsin.';
    }

    // Sohbet geçmişini al (eğer chatId varsa)
    List<Map<String, dynamic>>? chatHistory;
    if (chatId != null) {
      final messages = await DatabaseModel.select(
        DatabaseModel.chatMessagesTable,
        where: 'chat_id = ?',
        whereArgs: [chatId],
        orderBy: 'created_at ASC',
        limit: 10, // Son 10 mesajı al
      );

      if (messages.isNotEmpty) {
        chatHistory = messages
            .map(
              (msg) => {'message': msg['message'], 'is_user': msg['is_user']},
            )
            .toList();
      }
    }

    // Kullanıcı bilgilerini al
    final userInfo = await _getUserInfo(userId);

    // Use the more reliable generateResponse method with fallback
    final aiResponse = await AIReviewModel.generateResponse(
      input,
      type: type,
      mode: userMode,
      modeInstruction: modeInstruction,
      chatHistory: chatHistory,
      userInfo: userInfo,
    );

    await MessageModel.addAIComment(
      userId: userId,
      type: type,
      input: input,
      aiResponse: aiResponse,
      isFavorite: isFavorite,
      isShared: isShared,
    );
    return aiResponse;
  }
}
