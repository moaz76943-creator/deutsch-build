import 'dart:ui';

import 'package:sqflite_common/sqlite_api.dart';

import '../../services/sqlite_policy.dart';

enum GrammaticalClass {
  masculineNoun,
  feminineNoun,
  neuterNoun,
  pluralNoun,
  verb,
  adjective,
  other,
}

class SemanticColorTagging {
  static const Color masculineColor = Color(0xFF2563EB); // Slate Blue
  static const Color feminineColor = Color(0xFFE11D48); // Soft Crimson
  static const Color neuterColor = Color(0xFF0D9488); // Deep Teal
  static const Color pluralColor = Color(0xFF7C3AED); // Muted Violet
  static const Color defaultColor = Color(0xFF64748B); // Slate

  static const String _dbName = 'semantic_color_tags.db';
  static const String _tableName = 'semantic_tags';

  Database? _db;
  final AppSqlitePolicy _sqlitePolicy;
  final String? _inMemoryPath;

  SemanticColorTagging({DatabaseFactory? factory, String? path})
      : _sqlitePolicy = AppSqlitePolicy(factory: factory),
        _inMemoryPath = path;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = await _sqlitePolicy.resolvePath(
      fileName: _dbName,
      overridePath: _inMemoryPath,
    );
    return _sqlitePolicy.openWritable(
      path: path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        word TEXT NOT NULL,
        grammaticalClass TEXT NOT NULL,
        colorHex INTEGER NOT NULL
      )
    ''');
  }

  GrammaticalClass determineClass(String article, String word) {
    if (article == 'der') return GrammaticalClass.masculineNoun;
    if (article == 'die') return GrammaticalClass.feminineNoun;
    if (article == 'das') return GrammaticalClass.neuterNoun;

    if (word.isNotEmpty && word.endsWith('en') && word.toLowerCase() == word) {
      return GrammaticalClass.verb;
    }

    return GrammaticalClass.other;
  }

  Color getColorForClass(GrammaticalClass gClass) {
    switch (gClass) {
      case GrammaticalClass.masculineNoun:
        return masculineColor;
      case GrammaticalClass.feminineNoun:
        return feminineColor;
      case GrammaticalClass.neuterNoun:
        return neuterColor;
      case GrammaticalClass.pluralNoun:
        return pluralColor;
      default:
        return defaultColor;
    }
  }

  Future<void> tagAndSaveWord(
    String id,
    String word,
    String article, {
    bool isPlural = false,
  }) async {
    final gClass =
        isPlural ? GrammaticalClass.pluralNoun : determineClass(article, word);
    final color = getColorForClass(gClass);

    final db = await database;
    await db.insert(
        _tableName,
        {
          'id': id,
          'word': word,
          'grammaticalClass': gClass.name,
          'colorHex': color.toARGB32(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Color> getColorForWord(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      columns: ['colorHex'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Color(maps.first['colorHex'] as int);
    }
    return defaultColor;
  }

  Future<GrammaticalClass> getGrammaticalClassForWord(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      columns: ['grammaticalClass'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final className = maps.first['grammaticalClass'] as String;
      return GrammaticalClass.values.firstWhere(
        (e) => e.name == className,
        orElse: () => GrammaticalClass.other,
      );
    }
    return GrammaticalClass.other;
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
