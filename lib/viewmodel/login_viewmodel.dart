import 'package:flutter/material.dart';
import 'package:zodicomment/model/userModel.dart';

/// Login sayfası için ViewModel
/// Giriş işlemlerinin ve form durumunun yönetimini sağlar
class LoginViewModel extends ChangeNotifier {
  String nickname = '';
  String password = '';
  bool isLoading = false;
  String errorMessage = '';

  final formKey = GlobalKey<FormState>();

  /// Kullanıcı adı değerini günceller
  void setNickname(String value) {
    nickname = value.trim();
  }

  /// Şifre değerini günceller
  void setPassword(String value) {
    password = value;
  }

  /// Giriş işlemini gerçekleştirir
  Future<bool> login() async {
    if (!formKey.currentState!.validate()) return false;

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    formKey.currentState!.save();
    final result = await UserModel.login(nickname, password);

    isLoading = false;

    if (result['status'] == 'success') {
      notifyListeners();
      return true;
    } else {
      errorMessage = result['message'] ?? 'Giriş yapılırken bir hata oluştu';
      notifyListeners();
      return false;
    }
  }

  /// Form alanlarını doğrular
  String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı gerekli';
    }
    return null;
  }

  /// Şifre alanını doğrular
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    return null;
  }
}
