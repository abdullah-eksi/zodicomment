import 'package:flutter/material.dart';
import 'package:zodicomment/model/userModel.dart';

/// Kayıt sayfası için ViewModel
/// Kayıt işlemlerinin ve form durumunun yönetimini sağlar
class RegisterViewModel extends ChangeNotifier {
  String nickname = '';
  String userfullname = '';
  String password = '';
  String zodiac = 'Koç';
  String mode = 'eglenceli';
  bool notificationEnabled = true;
  bool isLoading = false;
  String errorMessage = '';

  final formKey = GlobalKey<FormState>();

  /// Burç listesi
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

  /// Kişilik modu listesi
  final List<String> modeList = [
    'eglenceli',
    'ciddi',
    'mistik',
    'romantik',
    'bilge',
    'elestirel',
  ];

  /// Burç ikonları
  final Map<String, IconData> zodiacIcons = {
    'Koç': Icons.whatshot,
    'Boğa': Icons.spa,
    'İkizler': Icons.people,
    'Yengeç': Icons.water,
    'Aslan': Icons.pets,
    'Başak': Icons.settings,
    'Terazi': Icons.balance,
    'Akrep': Icons.monitor_heart,
    'Yay': Icons.arrow_upward,
    'Oğlak': Icons.terrain,
    'Kova': Icons.waves,
    'Balık': Icons.water_drop,
  };

  /// Kullanıcı adını günceller
  void setNickname(String value) {
    nickname = value.trim();
  }

  /// Ad Soyadı günceller
  void setFullname(String value) {
    userfullname = value.trim();
  }

  /// Şifreyi günceller
  void setPassword(String value) {
    password = value;
  }

  /// Burcu günceller
  void setZodiac(String value) {
    zodiac = value;
    notifyListeners();
  }

  /// Kişilik modunu günceller
  void setMode(String value) {
    mode = value;
    notifyListeners();
  }

  /// Bildirim durumunu günceller
  void setNotificationEnabled(bool value) {
    notificationEnabled = value;
    notifyListeners();
  }

  /// Kullanıcı adını doğrular
  String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı gerekli';
    }
    return null;
  }

  /// Ad Soyadı doğrular
  String? validateFullname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad Soyad gerekli';
    }
    return null;
  }

  /// Şifreyi doğrular
  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'En az 6 karakter';
    }
    return null;
  }

  /// Kayıt işlemini gerçekleştirir
  Future<bool> register() async {
    if (!formKey.currentState!.validate()) return false;

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    formKey.currentState!.save();
    final result = await UserModel.register(
      nickname,
      userfullname,
      password,
      zodiac,
      mode,
      notificationEnabled,
    );

    isLoading = false;

    if (result['status'] == 'success') {
      notifyListeners();
      return true;
    } else {
      errorMessage = result['message'] ?? 'Kayıt yapılırken bir hata oluştu';
      notifyListeners();
      return false;
    }
  }
}
