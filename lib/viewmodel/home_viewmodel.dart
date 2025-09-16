import 'package:flutter/material.dart';
import 'package:zodicomment/model/messageModel.dart';
import 'package:zodicomment/model/userModel.dart';
import 'package:zodicomment/model/databaseModel.dart';
import 'package:zodicomment/routes.dart';

/// Home sayfası için view model
/// Sayfa state'ini ve iş mantığını yönetir
class HomeViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool waitingForAI = false;
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> chatHistory = [];
  int? currentChatId;
  final TextEditingController messageController = TextEditingController();

  /// Başlangıçta son sohbeti yükle
  Future<void> initializeChat() async {
    try {
      final userInfo = await UserModel.getUserInfo();
      if (userInfo['userId'] == null) return;

      final userId = int.parse(userInfo['userId'] ?? '0');

      // En son sohbeti bul
      final chats = await DatabaseModel.select(
        DatabaseModel.chatsTable,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (chats.isNotEmpty) {
        currentChatId = chats.first['id'];
        await loadChatMessages(currentChatId!);

        // Sohbet geçmişini yükle
        await loadChatHistory(userId);
      }
    } catch (e) {
      // Kritik hata, kullanıcıya gösterilmeli
      debugPrint('Sohbet başlatılırken hata: $e');
    }
  }

  /// Kullanıcının tüm sohbet geçmişini yükle
  Future<void> loadChatHistory(int userId) async {
    try {
      final chatList = await MessageModel.getUserChatsWithMode(userId);
      chatHistory.clear();
      for (var chat in chatList) {
        chatHistory.add({
          'id': chat['chatId'],
          'title': chat['title'],
          'isActive': chat['chatId'] == currentChatId,
        });
      }
      notifyListeners();
    } catch (e) {
      // Kritik hata, kullanıcıya gösterilmeli
      debugPrint('Sohbet geçmişi yüklenirken hata: $e');
    }
  }

  /// Çıkış yap
  Future<void> logout(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      await UserModel.logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Çıkış yapılırken hata oluştu: $e')),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Mesaj gönder
  Future<void> sendMessage(BuildContext context) async {
    final text = messageController.text.trim();
    if (text.isEmpty || waitingForAI) return;

    if (currentChatId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Önce bir sohbet seçin veya yeni sohbet oluşturun'),
          ),
        );
      }
      return;
    }

    isLoading = true;
    waitingForAI = true;
    notifyListeners();

    try {
      // Kullanıcı bilgilerini al
      final userInfo = await UserModel.getUserInfo();
      final userId = int.parse(userInfo['userId'] ?? '0');

      // Kullanıcı mesajını ekle
      await MessageModel.addMessage(
        chatId: currentChatId!,
        userId: userId,
        message: text,
        isUser: true,
      );

      // UI'a kullanıcı mesajını ekle
      messageController.clear();
      // Yeni mesajları veritabanından yükleyeceğiz, şimdilik sadece input'u temizle

      // Eğer bu sohbetteki ilk mesaj ise, sohbetin başlığını güncelle
      final chatMessages = await DatabaseModel.select(
        DatabaseModel.chatMessagesTable,
        where: 'chat_id = ?',
        whereArgs: [currentChatId],
      );

      if (chatMessages.length == 1) {
        // İlk mesajdan başlık oluştur
        final title = MessageModel.generateTitleFromMessage(text);
        await MessageModel.updateChatTitle(
          chatId: currentChatId!,
          newTitle: title,
        );

        // Sohbet geçmişini güncelle ve aktif sohbeti ayarla
        await loadChatHistory(userId);
      }

      // AI cevabını ekle
      final mode = userInfo['mode'] ?? 'eglenceli';
      final aiResponse = await MessageModel.generateAndSaveAIComment(
        userId: userId,
        type: 'sohbet',
        input: text,
        userMode: mode,
        chatId: currentChatId,
      );

      // AI mesajını ekle
      await MessageModel.addMessage(
        chatId: currentChatId!,
        userId: userId,
        message: aiResponse,
        isUser: false,
      );

      // Sohbetin tüm mesajlarını veritabanından yükle
      await loadChatMessages(currentChatId!);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mesaj gönderilirken hata: $e')));
      }
    } finally {
      isLoading = false;
      waitingForAI = false;
      notifyListeners();
    }
  }

  /// Sohbetin tüm mesajlarını veritabanından yükler
  Future<void> loadChatMessages(int chatId) async {
    try {
      final chatMessages = await DatabaseModel.select(
        DatabaseModel.chatMessagesTable,
        where: 'chat_id = ?',
        whereArgs: [chatId],
        orderBy:
            'created_at ASC', // Yeni mesajları ListView'ın altında göstermek için
      );

      messages.clear();
      for (var msg in chatMessages) {
        messages.add({'message': msg['message'], 'is_user': msg['is_user']});
      }
      notifyListeners();
    } catch (e) {
      // Kritik hata, kullanıcıya gösterilmeli
      debugPrint('Mesajlar yüklenirken hata: $e');
    }
  }

  /// Bir sohbet seçildiğinde
  Future<void> selectHistory(
    BuildContext context,
    Map<String, dynamic> chat,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      // Doğrudan chat ID'yi kullan
      final chatId = chat['id'];
      currentChatId = chatId;

      // Tüm sohbetlerde active sohbeti güncelle
      for (var i = 0; i < chatHistory.length; i++) {
        chatHistory[i]['isActive'] = chatHistory[i]['id'] == currentChatId;
      }

      // Sohbetin mesajlarını yükle
      await loadChatMessages(currentChatId!);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sohbet yüklenirken hata: $e')));
      }
    } finally {
      isLoading = false;
      notifyListeners();
      if (context.mounted) Navigator.of(context).pop(); // Drawer'ı kapat
    }
  }

  /// Yeni sohbet oluştur
  Future<void> newChat(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      // Kullanıcı bilgilerini al
      final userInfo = await UserModel.getUserInfo();
      final userId = int.parse(userInfo['userId'] ?? '0');

      // Boş bir sohbet oluştur
      currentChatId = await MessageModel.createNewChat(userId: userId);

      // Tüm sohbetlerde active sohbeti güncelle
      await loadChatHistory(userId);

      // Mesaj listesini temizle
      messages.clear();
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sohbet oluşturulurken hata: $e')),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
      if (context.mounted) Navigator.of(context).pop(); // Drawer'ı kapat
    }
  }

  /// Profil sayfasını aç
  void openProfile(BuildContext context) {
    // Drawer'ı kapat
    if (context.mounted) Navigator.of(context).pop();

    // Profil sayfasına yönlendir
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }

  /// Rehberlik mesajını al (boş liste veya sohbet seçilmediğinde)
  String? getGuidanceMessage() {
    if (messages.isEmpty) {
      if (chatHistory.isEmpty) {
        return "Yeni bir sohbet oluşturarak başlayın";
      } else if (currentChatId == null) {
        return "Bir sohbet seçin veya yeni bir sohbet oluşturun";
      }
    }
    return null;
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
