import 'package:sqflite_common/sqlite_api.dart';

import 'sqlite_policy.dart';

class CustomExample {
  final int id;
  final String wordId;
  final String germanSentence;
  final String arabicSentence;
  final DateTime createdAt;

  CustomExample({
    required this.id,
    required this.wordId,
    required this.germanSentence,
    required this.arabicSentence,
    required this.createdAt,
  });
}

class UserCustomization {
  final String wordId;
  final String? customArabicTranslation;
  final String? customNotes;
  final DateTime updatedAt;

  UserCustomization({
    required this.wordId,
    this.customArabicTranslation,
    this.customNotes,
    required this.updatedAt,
  });
}

class UserCustomizationService {
  UserCustomizationService({DatabaseFactory? factory, String? path})
      : _sqlitePolicy = AppSqlitePolicy(factory: factory),
        _overridePath = path;

  final AppSqlitePolicy _sqlitePolicy;
  final String? _overridePath;
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = await _sqlitePolicy.resolvePath(
      fileName: 'user_customizations.db',
      overridePath: _overridePath,
    );
    return _sqlitePolicy.openWritable(
      path: path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE user_vocab_customizations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word_id TEXT NOT NULL UNIQUE,
            custom_arabic_translation TEXT,
            custom_notes TEXT,
            updated_at TEXT NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE user_custom_examples (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word_id TEXT NOT NULL,
            german_sentence TEXT NOT NULL,
            arabic_sentence TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveTranslationOverride(
    String wordId,
    String customArabic,
    String? notes,
  ) async {
    final database = await db;
    await database.insert(
        'user_vocab_customizations',
        {
          'word_id': wordId,
          'custom_arabic_translation': customArabic,
          'custom_notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> resetTranslationOverride(String wordId) async {
    final database = await db;
    await database.delete(
      'user_vocab_customizations',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );
  }

  Future<void> addCustomExample(
    String wordId,
    String germanSentence,
    String arabicSentence,
  ) async {
    final database = await db;
    await database.insert('user_custom_examples', {
      'word_id': wordId,
      'german_sentence': germanSentence,
      'arabic_sentence': arabicSentence,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteCustomExample(int exampleId) async {
    final database = await db;
    await database.delete(
      'user_custom_examples',
      where: 'id = ?',
      whereArgs: [exampleId],
    );
  }

  Future<List<CustomExample>> getCustomExamples(String wordId) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'user_custom_examples',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );
    return List.generate(maps.length, (i) {
      return CustomExample(
        id: maps[i]['id'] as int,
        wordId: maps[i]['word_id'] as String,
        germanSentence: maps[i]['german_sentence'] as String,
        arabicSentence: maps[i]['arabic_sentence'] as String,
        createdAt: DateTime.parse(maps[i]['created_at'] as String),
      );
    });
  }

  Future<UserCustomization?> getCustomization(String wordId) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'user_vocab_customizations',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );
    if (maps.isEmpty) {
      return null;
    }
    return UserCustomization(
      wordId: maps[0]['word_id'] as String,
      customArabicTranslation: maps[0]['custom_arabic_translation'] as String?,
      customNotes: maps[0]['custom_notes'] as String?,
      updatedAt: DateTime.parse(maps[0]['updated_at'] as String),
    );
  }
}
