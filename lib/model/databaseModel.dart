import 'package:zodicomment/model/userModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.html) 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseModel {
  static Database? _database;

  static String usersTable = 'users';
  static String commentsTable = 'comments';
  static String chatsTable = 'chats';
  static String chatMessagesTable = 'chat_messages';

  static void _ensureInitialized() {
    try {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } else if (Platform.isAndroid || Platform.isIOS) {
      } else {}
    } catch (e) {
      print("Error initializing database factory: $e");
    }
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    try {
      _ensureInitialized();

      String documentsPath;

      if (Platform.isWindows) {
        documentsPath = Platform.environment['USERPROFILE'] ?? '';
        documentsPath = join(documentsPath, 'Documents', 'ZodiComment');
      } else if (Platform.isLinux) {
        documentsPath = Platform.environment['HOME'] ?? '';
        documentsPath = join(documentsPath, '.zodicomment');
      } else if (Platform.isAndroid || Platform.isIOS) {
        documentsPath = await getDatabasesPath();
      } else {
        documentsPath = await getDatabasesPath();
      }

      final directory = Directory(documentsPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      String path = join(documentsPath, 'zodicomment.db');

      _ensureInitialized();

      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );

      await _ensureTablesExist(db);

      return db;
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  static Future<void> _ensureTablesExist(Database db) async {
    try {
      // Mevcut tabloları al
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';",
      );

      final List<String> tableNames = tables
          .map((t) => t['name'] as String)
          .toList();

      // print('Existing tables: $tableNames');

      // Tablolar yoksa oluştur
      if (!tableNames.contains(usersTable)) {
        // print('Creating missing table: $usersTable');
        await _createUsersTable(db);
      }

      if (!tableNames.contains(commentsTable)) {
        // print('Creating missing table: $commentsTable');
        await _createCommentsTable(db);
      }

      if (!tableNames.contains(chatsTable)) {
        // print('Creating missing table: $chatsTable');
        await _createChatsTable(db);
      }

      if (!tableNames.contains(chatMessagesTable)) {
        // print('Creating missing table: $chatMessagesTable');
        await _createChatMessagesTable(db);
      }
    } catch (e) {
      print('Error ensuring tables exist: $e');
      rethrow;
    }
  }

  static Future<void> _createDatabase(Database db, int version) async {
    await _createUsersTable(db);
    await _createCommentsTable(db);
    await _createChatsTable(db);
    await _createChatMessagesTable(db);

    final existingUser = await db.query(
      'users',
      where: "nickname = ?",
      whereArgs: ['Genel'],
      limit: 1,
    );
    if (existingUser.isEmpty) {
      await db.insert('users', {
        'nickname': 'Admin',
        'userfullname': 'Abdullah Ekşi',
        'password': UserModel.hashPassword('123456'),
        'zodiac': 'Koç',
        'mode': 'eglenceli',
        'notification_enabled': 1,
        'favorite_comments': '',
      });
    }
  }

  // Bireysel tablo oluşturma metotları
  static Future<void> _createUsersTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nickname TEXT NOT NULL UNIQUE,
          userfullname TEXT NOT NULL,
          password TEXT NOT NULL,
          zodiac TEXT,
          mode TEXT DEFAULT 'eglenceli',
          notification_enabled INTEGER DEFAULT 1,
          favorite_comments TEXT,
          loginTime TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      // print('users table created successfully');
    } catch (e) {
      print('Error creating users table: $e');
      rethrow;
    }
  }

  static Future<void> _createCommentsTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS comments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          type TEXT NOT NULL, -- burc, ruya, fal
          input TEXT NOT NULL,
          ai_response TEXT NOT NULL,
          is_favorite INTEGER DEFAULT 0,
          is_shared INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
      print('comments table created successfully');
    } catch (e) {
      print('Error creating comments table: $e');
      rethrow;
    }
  }

  static Future<void> _createChatsTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS chats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
      print('chats table created successfully');
    } catch (e) {
      print('Error creating chats table: $e');
      rethrow;
    }
  }

  static Future<void> _createChatMessagesTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS chat_messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          chat_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          message TEXT NOT NULL,
          is_user INTEGER DEFAULT 1,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (chat_id) REFERENCES chats (id),
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
      print('chat_messages table created successfully');
    } catch (e) {
      print('Error creating chat_messages table: $e');
      rethrow;
    }
  }

  static Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Gerekirse versiyon yükseltme işlemleri burada yapılabilir
  }

  // Veritabanını manuel olarak oluştur/yükselt
  static Future<void> initializeDatabase() async {
    final db = await database;
    print('Manually initializing database...');
    await _ensureTablesExist(db);
    print('Database initialization completed.');
  }

  // Veritabanı durumunu kontrol et ve tamir et
  static Future<Map<String, dynamic>> checkAndRepairDatabase() async {
    final db = await database;
    final results = <String, dynamic>{};

    try {
      // Mevcut tabloları al
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';",
      );

      final List<String> tableNames = tables
          .map((t) => t['name'] as String)
          .toList();
      results['existing_tables'] = tableNames;

      // Eksik tabloları kontrol et ve oluştur
      final requiredTables = [
        usersTable,
        commentsTable,
        chatsTable,
        chatMessagesTable,
      ];
      final missingTables = <String>[];

      for (final table in requiredTables) {
        if (!tableNames.contains(table)) {
          missingTables.add(table);

          // Eksik tabloyu oluştur
          if (table == usersTable) await _createUsersTable(db);
          if (table == commentsTable) await _createCommentsTable(db);
          if (table == chatsTable) await _createChatsTable(db);
          if (table == chatMessagesTable) await _createChatMessagesTable(db);
        }
      }

      results['missing_tables'] = missingTables;
      results['repair_status'] = 'success';

      // Tekrar tabloları kontrol et
      final List<Map<String, dynamic>> tablesAfterFix = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';",
      );

      final List<String> tableNamesAfterFix = tablesAfterFix
          .map((t) => t['name'] as String)
          .toList();
      results['tables_after_fix'] = tableNamesAfterFix;

      return results;
    } catch (e) {
      results['error'] = e.toString();
      results['repair_status'] = 'failed';
      return results;
    }
  }

  // Veritabanını sıfırla
  // Veritabanını tamamen sıfırlar (geliştirme amaçlı)
  // Yayına hazır uygulamada bu fonksiyon kullanılmamalıdır
  /*
  static Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS chat_messages');
    await db.execute('DROP TABLE IF EXISTS chats');
    await db.execute('DROP TABLE IF EXISTS comments');
    await db.execute('DROP TABLE IF EXISTS users');
    await _createDatabase(db, 1);
  }
  */

  // Veritabanı tanı metodları (geliştirme amaçlı)
  // Yayına hazır uygulamada bu fonksiyon kullanılmamalıdır
  /*
  static Future<Map<String, dynamic>> diagnoseDatabaseIssues() async {
    final results = <String, dynamic>{};

    try {
      final db = await database;
      results['database_path'] = db.path;
      results['database_version'] = await db.getVersion();

      // Tüm tabloları al
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';",
      );

      final List<String> tableNames = tables
          .map((t) => t['name'] as String)
          .toList();
      results['existing_tables'] = tableNames;

      // Gerekli tabloların eksik olanlarını kontrol et
      final requiredTables = [
        usersTable,
        commentsTable,
        chatsTable,
        chatMessagesTable,
      ];
      final missingTables = requiredTables
          .where((t) => !tableNames.contains(t))
          .toList();
      results['missing_tables'] = missingTables;

      // Her tablo için detay bilgilerini al
      final tableDetails = <String, dynamic>{};

      for (final tableName in tableNames) {
        final tableInfo = <String, dynamic>{};

        // Tablo yapısını al
        try {
          final List<Map<String, dynamic>> columns = await db.rawQuery(
            "PRAGMA table_info('$tableName');",
          );
          tableInfo['columns'] = columns
              .map(
                (c) => {
                  'name': c['name'],
                  'type': c['type'],
                  'not_null': c['notnull'],
                  'primary_key': c['pk'] == 1,
                },
              )
              .toList();

          // Kayıt sayısını al
          final countResult = await db.rawQuery(
            'SELECT COUNT(*) as count FROM $tableName',
          );
          final count = countResult.first['count'] as int? ?? 0;
          tableInfo['record_count'] = count;

          // İlk 3 kaydı al
          if (count > 0) {
            try {
              final sampleData = await db.query(tableName, limit: 3);
              tableInfo['sample_data'] = sampleData;
            } catch (e) {
              tableInfo['sample_data_error'] = e.toString();
            }
          }
        } catch (e) {
          tableInfo['error'] = e.toString();
        }

        tableDetails[tableName] = tableInfo;
      }

      results['table_details'] = tableDetails;
      results['status'] = 'success';

      return results;
    } catch (e) {
      results['error'] = e.toString();
      results['status'] = 'failed';
      return results;
    }
  }
  */

  // Veritabanı şemasını yazdır (debug için)
  // Yayına hazır uygulamada bu fonksiyon kullanılmamalıdır
  /*
  static Future<void> printDatabaseSchema() async {
    final db = await database;
    try {
      // Tüm tabloları al
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';",
      );

      print('=== Database Schema Information ===');
      print('Database path: ${db.path}');
      print('Database version: ${await db.getVersion()}');
      print('Tables found: ${tables.length}');

      // Her tablonun yapısını yazdır
      for (final table in tables) {
        final tableName = table['name'] as String;
        print('\nTable: $tableName');

        // Tablo yapısını al
        final List<Map<String, dynamic>> columns = await db.rawQuery(
          "PRAGMA table_info('$tableName');",
        );

        print('Columns:');
        for (final column in columns) {
          print(
            '  - ${column['name']} (${column['type']})${column['pk'] == 1 ? ' PRIMARY KEY' : ''}',
          );
        }

        // Kayıt sayısını al
        final countResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $tableName',
        );
        final count = countResult.first['count'];
        print('Record count: $count');
      }

      print('=== End of Schema Information ===');
    } catch (e) {
      print('Error printing database schema: $e');
    }
  }
  */

  // CRUD Fonksiyonları
  static Future<List<Map<String, dynamic>>> select(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  static Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Yardımcı Fonksiyonlar
  static Future<Map<String, dynamic>?> getUserByNickname(
    String nickname,
  ) async {
    final results = await select(
      'users',
      where: 'nickname = ?',
      whereArgs: [nickname],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
