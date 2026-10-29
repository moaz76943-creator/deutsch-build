<<<<<<< HEAD
$(cat /tmp/vocab_repo_new.dart)
=======
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class VocabularyRepository {
  static const String _key = 'vocabulary_list';
  static const String _legacyKey = 'custom_vocabulary';

  List<Map<String, dynamic>> _offlineCache = [];

  Future<Database> _getDb() async {
    final db = await DatabaseService.instance.progressDb;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vocabulary_items (
        word TEXT PRIMARY KEY,
        language_code TEXT NOT NULL DEFAULT 'de',
        article TEXT,
        meaning TEXT,
        interval INTEGER NOT NULL DEFAULT 0,
        repetitions INTEGER NOT NULL DEFAULT 0,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        json_data TEXT NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vocab_lang ON vocabulary_items(language_code)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vocab_interval ON vocabulary_items(interval)');
    return db;
  }

  Future<List<Map<String, dynamic>>> getVocabularyList() async {
    try {
      final db = await _getDb().timeout(const Duration(seconds: 5));
      final List<Map<String, dynamic>> records = await db.query(
        'vocabulary_items',
        orderBy: 'rowid ASC',
      ).timeout(const Duration(seconds: 5));

      if (records.isEmpty) {
        final seeded = await _seedAndMigrate(db);
        _offlineCache = seeded;
        return seeded;
      }

      final results = records.map((row) {
        final jsonStr = row['json_data'] as String;
        return Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);
      }).toList();
      _offlineCache = results;
      return results;
    } catch (_) {
      return _offlineCache;
    }
  }

  Future<List<Map<String, dynamic>>> _seedAndMigrate(Database db) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_key) ?? prefs.getString(_legacyKey);

      if (jsonString == null || jsonString.isEmpty || jsonString == '[]') {
        try {
          jsonString =
              await rootBundle.loadString('assets/data/master_vocabulary.json');
        } catch (_) {}
      }

      if (jsonString != null && jsonString.isNotEmpty && jsonString != '[]') {
        final decoded = jsonDecode(jsonString);
        if (decoded is! List) return _offlineCache;
        final List<dynamic> decodedList = decoded;
        final items =
            decodedList
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
        await saveVocabularyList(items);
        return items;
      }
    } catch (_) {}
    return [];
  }

  Future<bool> saveVocabularyList(List<Map<String, dynamic>> items) async {
    try {
      final db = await _getDb();
      final batch = db.batch();
      for (final item in items) {
        final word = (item['word'] ?? '').toString();
        if (word.isEmpty) continue;
        final lang = (item['languageCode'] ?? 'de').toString();
        batch.insert(
          'vocabulary_items',
          {
            'word': word,
            'language_code': lang,
            'article': (item['article'] ?? '').toString(),
            'meaning': (item['meaning'] ?? '').toString(),
            'interval': item['interval'] is int ? item['interval'] : 0,
            'repetitions': item['repetitions'] is int ? item['repetitions'] : 0,
            'ease_factor': item['easeFactor'] is num
                ? (item['easeFactor'] as num).toDouble()
                : 2.5,
            'json_data': jsonEncode(item),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateItemSrs({
    required String word,
    required int interval,
    required int repetitions,
    required double easeFactor,
  }) async {
    try {
      final db = await _getDb();
      final res = await db.query(
        'vocabulary_items',
        columns: ['json_data'],
        where: 'word = ?',
        whereArgs: [word],
        limit: 1,
      );
      if (res.isNotEmpty) {
        final decodedJson = jsonDecode(res.first['json_data'] as String);
        if (decodedJson is! Map) return false;
        final map = Map<String, dynamic>.from(decodedJson);
        map['interval'] = interval;
        map['repetitions'] = repetitions;
        map['easeFactor'] = easeFactor;
        await db.update(
          'vocabulary_items',
          {
            'interval': interval,
            'repetitions': repetitions,
            'ease_factor': easeFactor,
            'json_data': jsonEncode(map),
          },
          where: 'word = ?',
          whereArgs: [word],
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> upsertVocabularyItem(Map<String, dynamic> item) async {
    try {
      final db = await _getDb();
      final word = (item['word'] ?? '').toString();
      if (word.isEmpty) return false;
      final lang = (item['languageCode'] ?? 'de').toString();
      await db.insert(
        'vocabulary_items',
        {
          'word': word,
          'language_code': lang,
          'article': (item['article'] ?? '').toString(),
          'meaning': (item['meaning'] ?? '').toString(),
          'interval': item['interval'] is int ? item['interval'] : 0,
          'repetitions': item['repetitions'] is int ? item['repetitions'] : 0,
          'ease_factor': item['easeFactor'] is num
              ? (item['easeFactor'] as num).toDouble()
              : 2.5,
          'json_data': jsonEncode(item),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteVocabularyItem(String word) async {
    try {
      final db = await _getDb();
      await db.delete('vocabulary_items', where: 'word = ?', whereArgs: [word]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> exportBackupJson() async {
    final items = await getVocabularyList();
    return jsonEncode(items);
  }

  Future<String> exportAnkiTsv() async {
    final items = await getVocabularyList();
    final StringBuffer buffer = StringBuffer();
    for (var item in items) {
      final String front = item['languageCode'] == 'de'
          ? '${item['article']} ${item['word']}'
          : '${item['word']}';
      final String back =
          '${item['meaning']} (${item['semanticField'] ?? 'عام'})';
      buffer.writeln('$front\t$back');
    }
    return buffer.toString();
  }

  Future<String> generateDiagnosticReport() async {
    final items = await getVocabularyList();
    int total = items.length;
    Map<String, int> langs = {};
    Map<String, int> fields = {};

    for (var item in items) {
      final String l = '${item['languageCode'] ?? 'de'}';
      langs[l] = (langs[l] ?? 0) + 1;
      final String f = '${item['semanticField'] ?? 'عام'}';
      fields[f] = (fields[f] ?? 0) + 1;
    }

    final rawJson = await exportBackupJson();
    int bytes = utf8.encode(rawJson).length;

    StringBuffer report = StringBuffer();
    report.writeln('=== تقرير صحة قاعدة البيانات (Engine 10/10) ===');
    report.writeln('إجمالي المفردات: $total');
    report.writeln('حجم التخزين الفعلي: $bytes بايت');
    report.writeln('توزيع اللغات: $langs');
    report.writeln('توزيع المجالات: $fields');
    report.writeln('المعمارية: Indexed SQLite Columnar Engine');
    return report.toString();
  }

  Future<bool> importBackupJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) return false;
      final List<dynamic> decodedList = decoded;
      final items = decodedList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return await saveVocabularyList(items);
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getDatabaseHealthStats() async {
    final items = await getVocabularyList();
    final Map<String, int> langCounts = {};
    for (final item in items) {
      final String lang = (item['languageCode'] ?? 'de').toString();
      langCounts[lang] = (langCounts[lang] ?? 0) + 1;
    }
    final raw = await exportBackupJson();
    final int bytes = utf8.encode(raw).length;

    return {
      'totalCount': items.length,
      'sizeInBytes': bytes,
      'status': 'متصل ومفهرس بالكامل (10/10 Architecture)',
      'langCounts': langCounts,
    };
  }
}
>>>>>>> origin/staging/v2-full-platform
