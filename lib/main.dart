import 'package:flutter/material.dart';
import 'package:zodicomment/routes.dart';
import 'package:zodicomment/model/databaseModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını yükle
  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await DatabaseModel.checkAndRepairDatabase();
    await DatabaseModel.initializeDatabase();
  } catch (e) {
    print("Database initialization error: $e");
  }
  runApp(const ZodiCommentApp());
}

class ZodiCommentApp extends StatelessWidget {
  const ZodiCommentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZodiComment',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => _buildNotFoundPage(context),
        );
      },
    );
  }

  // 404 sayfası (Sayfa bulunamadı ekranı)
  Widget _buildNotFoundPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sayfa Bulunamadı'),
        backgroundColor: const Color(0xFF8F94FB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              '404 - Sayfa Bulunamadı',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Aradığınız sayfa mevcut değil',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8F94FB),
                foregroundColor: Colors.white,
              ),
              child: const Text('ZodiComment Ana Sayfa'),
            ),
          ],
        ),
      ),
    );
  }
}
