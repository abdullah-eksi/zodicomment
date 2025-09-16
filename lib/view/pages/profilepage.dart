import 'package:flutter/material.dart';
import 'package:zodicomment/model/userModel.dart';
import 'package:zodicomment/model/messageModel.dart';
import 'package:zodicomment/routes.dart';

import 'package:zodicomment/view/components/components.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic> _userInfo = {};
  String _selectedMode = 'eglenceli';
  String _selectedZodiac = 'Koç';
  List<Map<String, dynamic>> chatHistory = [];

  final List<String> zodiacList = [
    'Koç',
    'Boğa',
    'İkizler',
    'Yengeç',
    'Aslan',
    'Başak',
    'Terazi',
    'Akrep',
    'Yay',
    'Oğlak',
    'Kova',
    'Balık',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Veritabanından kullanıcı bilgilerini al
      final userInfo = await UserModel.getUserInfoFromDatabase();

      if (userInfo.isNotEmpty) {
        final userId = int.parse(userInfo['userId'] ?? '0');

        // Sohbet geçmişini yükle
        if (userId > 0) {
          final chatList = await MessageModel.getUserChatsWithMode(userId);

          setState(() {
            chatHistory.clear();
            for (var chat in chatList) {
              chatHistory.add({
                'id': chat['chatId'],
                'title': chat['title'],
                'isActive': false,
              });
            }
          });
        }

        setState(() {
          _userInfo = userInfo;
          _selectedMode = userInfo['mode'] ?? 'eglenceli';
          _selectedZodiac = userInfo['zodiac'] ?? 'Koç';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı bilgileri yüklenirken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserMode(String mode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await UserModel.updateUserMode(mode);

      setState(() {
        _selectedMode = mode;
        _userInfo['mode'] = mode;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kişilik modu güncellendi')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kişilik modu güncellenirken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserZodiac(String zodiac) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await UserModel.updateUserZodiac(zodiac);

      setState(() {
        _selectedZodiac = zodiac;
        _userInfo['zodiac'] = zodiac;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Burç bilgisi güncellendi')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Burç bilgisi güncellenirken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAllChats() async {
    // Confirm dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sohbet Geçmişini Sil'),
        content: const Text(
          'Tüm sohbet geçmişiniz silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = int.parse(_userInfo['userId'] ?? '0');
      if (userId > 0) {
        await MessageModel.deleteAllUserChats(userId);

        setState(() {
          chatHistory.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tüm sohbet geçmişi silindi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sohbet geçmişi silinirken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToChat(Map<String, dynamic> chat) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _newChat() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            tooltip: 'Menü',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: SidebarMenu(
            chatHistory: chatHistory,
            onNewChat: _newChat,
            onSelectChat: _navigateToChat,
            onClose: () => Navigator.of(context).pop(),
            onProfileTap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profil Başlık (Avatar ve Kullanıcı Bilgileri)
                    ProfileHeader(userInfo: _userInfo),

                    // Kişilik Modu Seçimi
                    ModeSelector(
                      selectedMode: _selectedMode,
                      onModeChanged: _updateUserMode,
                    ),

                    // Burç Seçimi
                    ZodiacSelector(
                      selectedZodiac: _selectedZodiac,
                      zodiacList: zodiacList,
                      onZodiacChanged: _updateUserZodiac,
                    ),

                    // Profil İşlemleri (Sohbet Geçmişi Silme ve Çıkış)
                    ProfileActions(
                      userInfo: _userInfo,
                      onDeleteChats: _deleteAllChats,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
