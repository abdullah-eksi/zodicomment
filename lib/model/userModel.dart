import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zodicomment/model/databaseModel.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final int? id;
  String nickname;
  String userfullname;
  String password;
  String? zodiac;
  String? mode;
  bool notificationEnabled;
  String? favoriteComments;

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  UserModel({
    this.id,
    required this.nickname,
    required this.userfullname,
    required this.password,
    this.zodiac,
    this.mode,
    this.notificationEnabled = true,
    this.favoriteComments,
  });

  UserModel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      nickname = json['nickname'],
      userfullname = json['userfullname'],
      password = json['password'],
      zodiac = json['zodiac'],
      mode = json['mode'],
      notificationEnabled = (json['notification_enabled'] ?? 1) == 1,
      favoriteComments = json['favorite_comments'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'userfullname': userfullname,
      'password': password,
      'zodiac': zodiac,
      'mode': mode,
      'notification_enabled': notificationEnabled ? 1 : 0,
      'favorite_comments': favoriteComments,
    };
  }

  // Şifre hashleme
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Kullanıcı kayıt
  static Future<Map<String, String>> register(
    String nickname,
    String userfullname,
    String password,
    String zodiac,
    String mode,
    bool notificationEnabled,
  ) async {
    if (nickname.isEmpty ||
        userfullname.isEmpty ||
        password.isEmpty ||
        zodiac.isEmpty ||
        mode.isEmpty) {
      return {"status": "error", "message": "Tüm alanlar doldurulmalıdır"};
    }

    if (password.length < 6) {
      return {"status": "error", "message": "Şifre en az 6 karakter olmalıdır"};
    }

    // Kullanıcı adı kontrolü
    final existingUser = await DatabaseModel.getUserByNickname(nickname);
    if (existingUser != null) {
      return {
        "status": "error",
        "message": "Bu kullanıcı adı zaten kullanılıyor",
      };
    }

    try {
      // Kullanıcı ekleme
      final userId = await DatabaseModel.insert(DatabaseModel.usersTable, {
        'nickname': nickname,
        'userfullname': userfullname,
        'password': UserModel.hashPassword(password),
        'zodiac': zodiac,
        'mode': mode,
        'notification_enabled': notificationEnabled ? 1 : 0,
        'favorite_comments': '',
        'loginTime': DateTime.now().toIso8601String(),
      });

      // Oturum kaydet
      await saveSession(
        userId: userId.toString(),
        nickname: nickname,
        userfullname: userfullname,
        zodiac: zodiac,
        mode: mode,
        notificationEnabled: notificationEnabled,
      );

      return {"status": "success", "message": "Kayıt başarılı"};
    } catch (e) {
      return {"status": "error", "message": "Kayıt sırasında hata oluştu: $e"};
    }
  }

  // Kullanıcı giriş
  static Future<Map<String, String>> login(
    String nickname,
    String password,
  ) async {
    if (nickname.isEmpty || password.isEmpty) {
      return {
        "status": "error",
        "message": "Kullanıcı adı veya şifre boş olamaz",
      };
    }

    try {
      // Kullanıcı kontrolü
      final user = await DatabaseModel.getUserByNickname(nickname);
      if (user == null) {
        return {
          "status": "error",
          "message": "Hatalı Şifre Veya Kullanıcı Adı ",
        };
      }

      // Şifre kontrolü
      if (user['password'] != UserModel.hashPassword(password)) {
        return {
          "status": "error",
          "message": "Hatalı şifre Veya kullanıcı adı",
        };
      }

      // Login time güncelle
      await DatabaseModel.update(
        DatabaseModel.usersTable,
        {'loginTime': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [user['id']],
      );

      // Oturum kaydet
      await saveSession(
        userId: user['id'].toString(),
        nickname: user['nickname'],
        userfullname: user['userfullname'],
      );

      return {"status": "success", "message": "Giriş başarılı"};
    } catch (e) {
      return {"status": "error", "message": "Giriş sırasında hata oluştu: $e"};
    }
  }

  // Oturum kaydetme
  static Future<void> saveSession({
    required String userId,
    required String nickname,
    required String userfullname,
    String? zodiac,
    String? mode,
    bool? notificationEnabled,
  }) async {
    await _storage.write(key: 'isLoggedIn', value: 'true');
    await _storage.write(key: 'userId', value: userId);
    await _storage.write(key: 'nickname', value: nickname);
    await _storage.write(key: 'userfullname', value: userfullname);
    if (zodiac != null) await _storage.write(key: 'zodiac', value: zodiac);
    if (mode != null) await _storage.write(key: 'mode', value: mode);
    if (notificationEnabled != null)
      await _storage.write(
        key: 'notification_enabled',
        value: notificationEnabled ? '1' : '0',
      );
    await _storage.write(
      key: 'loginTime',
      value: DateTime.now().toIso8601String(),
    );
  }

  // Oturum kontrolü
  static Future<bool> isLoggedIn() async {
    final String? isLoggedIn = await _storage.read(key: 'isLoggedIn');
    return isLoggedIn == 'true';
  }

  // Kullanıcı bilgilerini getir
  static Future<Map<String, String?>> getUserInfo() async {
    return {
      'userId': await _storage.read(key: 'userId'),
      'nickname': await _storage.read(key: 'nickname'),
      'userfullname': await _storage.read(key: 'userfullname'),
      'zodiac': await _storage.read(key: 'zodiac'),
      'mode': await _storage.read(key: 'mode'),
      'notification_enabled': await _storage.read(key: 'notification_enabled'),
      'loginTime': await _storage.read(key: 'loginTime'),
    };
  }

  // Çıkış işlemi
  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  // Oturum süresi kontrolü (1 gün)
  static Future<bool> isSessionValid() async {
    final String? loginTimeStr = await _storage.read(key: 'loginTime');
    if (loginTimeStr == null) return false;

    final DateTime loginTime = DateTime.parse(loginTimeStr);
    final Duration difference = DateTime.now().difference(loginTime);

    // 1 günden fazla ise oturum geçersiz
    return difference.inDays < 1;
  }

  // Kullanıcı modunu güncelle
  static Future<void> updateUserMode(String mode) async {
    final userInfo = await getUserInfo();
    final userId = userInfo['userId'];

    if (userId == null) return;

    // Veritabanında kullanıcı modunu güncelle
    await DatabaseModel.update(
      DatabaseModel.usersTable,
      {'mode': mode},
      where: 'id = ?',
      whereArgs: [int.parse(userId)],
    );

    // Secure storage'da da güncelle
    await _storage.write(key: 'mode', value: mode);
  }

  // Kullanıcı burcunu güncelle
  static Future<void> updateUserZodiac(String zodiac) async {
    final userInfo = await getUserInfo();
    final userId = userInfo['userId'];

    if (userId == null) return;

    // Veritabanında kullanıcı burcunu güncelle
    await DatabaseModel.update(
      DatabaseModel.usersTable,
      {'zodiac': zodiac},
      where: 'id = ?',
      whereArgs: [int.parse(userId)],
    );

    // Secure storage'da da güncelle
    await _storage.write(key: 'zodiac', value: zodiac);
  }

  static Future getUserById(int userId) async {
    final user = await DatabaseModel.select(
      DatabaseModel.usersTable,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    return user.isNotEmpty ? user.first : null;
  }

  // Kullanıcı bilgilerini veritabanından getir
  static Future<Map<String, dynamic>> getUserInfoFromDatabase() async {
    try {
      // Önce secure storage'dan userId'yi al
      final userInfo = await getUserInfo();
      final userId = userInfo['userId'];

      if (userId == null || userId.isEmpty) {
        return {};
      }

      // Veritabanından kullanıcı bilgilerini çek
      final user = await getUserById(int.parse(userId));

      if (user == null) {
        return {};
      }

      // Veritabanı verilerini ve storage verilerini birleştir
      return {
        'userId': userId,
        'nickname': user['nickname'],
        'userfullname': user['userfullname'],
        'zodiac': user['zodiac'],
        'mode': user['mode'],
        'notification_enabled': user['notification_enabled'] == 1 ? '1' : '0',
        'loginTime': user['loginTime'],
      };
    } catch (e) {
      debugPrint('Veritabanından kullanıcı bilgileri alınırken hata: $e');
      return {};
    }
  }
}
