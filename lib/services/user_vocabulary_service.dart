import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'database_migration_helper.dart';

class UserVocabularyService {
  static final UserVocabularyService instance = UserVocabularyService._init();
  static Database? _database;

  UserVocabularyService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_vocabulary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await DatabaseMigrationHelper.open(
      path: path,
      version: 1,
      onCreate: _createDB,
      migrationScripts: {},
    );
  }

  Future<void> addCustomEntry(Map<String, dynamic> entry) async {
    final db = await instance.database;
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.insert(
        'user_vocabulary',
        entry,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getCustomEntries({
    String? targetLanguage,
  }) async {
    final db = await instance.database;
    if (targetLanguage != null && targetLanguage.isNotEmpty) {
      return await db.query(
        'user_vocabulary',
        where: 'target_language = ?',
        whereArgs: [targetLanguage],
        orderBy: 'created_at DESC',
      );
    }
    return await db.query('user_vocabulary', orderBy: 'created_at DESC');
  }

  Future<void> deleteCustomEntry(String id) async {
    final db = await instance.database;
    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.delete('user_vocabulary', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vocabulary_favorites (
        id TEXT PRIMARY KEY,
        is_favorite INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_vocabulary (
        id TEXT PRIMARY KEY,
        german_text TEXT NOT NULL,
        arabic_translation TEXT NOT NULL,
        article TEXT,
        notes TEXT,
        example_sentence TEXT,
        created_at TEXT NOT NULL,
        is_custom INTEGER NOT NULL
      )
    ''');
  }
}

class FavoritesRepository {
  static final FavoritesRepository instance = FavoritesRepository._init();
  FavoritesRepository._init();

  Future<void> toggleFavorite(String id) async {
    final db = await UserVocabularyService.instance.database;

    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      final maps = await txn.query(
        'vocabulary_favorites',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        await txn.insert('vocabulary_favorites', {'id': id, 'is_favorite': 1});
      } else {
        final current = maps.first['is_favorite'] as int;
        await txn.update(
          'vocabulary_favorites',
          {'is_favorite': current == 1 ? 0 : 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }

  Future<bool> isFavorite(String id) async {
    final db = await UserVocabularyService.instance.database;
    final maps = await db.query(
      'vocabulary_favorites',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return false;
    return (maps.first['is_favorite'] as int) == 1;
  }

  Future<Set<String>> getFavorites() async {
    final db = await UserVocabularyService.instance.database;
    final maps = await db.query(
      'vocabulary_favorites',
      where: 'is_favorite = 1',
    );

    return maps.map((e) => e['id'] as String).toSet();
  }
}
