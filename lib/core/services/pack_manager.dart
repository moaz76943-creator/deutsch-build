import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive.dart';

Uint8List _decompressGzip(Uint8List compressedBytes) {
  return Uint8List.fromList(GZipDecoder().decodeBytes(compressedBytes));
}

class PackManager {
  static Database? _database;
  static String? _currentLanguage;

  static Future<Database> initLanguagePack(String langCode) async {
    if (_database != null && _currentLanguage == langCode) {
      return _database!;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docsDir.path, '$langCode-1.0.0.sqlite');
    final tempPath = join(docsDir.path, '$langCode-1.0.0.sqlite.tmp');

    if (!await File(dbPath).exists()) {
      final assetPath = 'assets/content/packs/$langCode/$langCode-1.0.0.pack.gz';
      final byteData = await rootBundle.load(assetPath);
      final compressedBytes = byteData.buffer.asUint8List();

      final decompressedBytes = await compute(_decompressGzip, compressedBytes);

      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(decompressedBytes, flush: true);
      await tempFile.rename(dbPath);
    }

    _database = await openDatabase(dbPath, readOnly: false);
    _currentLanguage = langCode;
    return _database!;
  }

  static Future<List<Map<String, dynamic>>> getConceptsBySection({
    required String sectionId,
    required String cefr,
  }) async {
    if (_database == null) throw Exception('Database not initialized');

    return await _database!.rawQuery('''
      SELECT 
        c.concept_id,
        COALESCE(l.display_text, l.lemma) AS word,
        l.part_of_speech,
        l.gender,
        l.plural,
        COALESCE(up.box_level, 0) AS box_level
      FROM concepts c
      JOIN lexicon l ON l.concept_id = c.concept_id
      LEFT JOIN user_progress up ON up.concept_id = c.concept_id
      WHERE c.section_id = ? AND c.cefr = ?;
    ''', [sectionId, cefr]);
  }

  static Future<List<Map<String, dynamic>>> searchInstant(String query) async {
    if (_database == null) throw Exception('Database not initialized');

    return await _database!.rawQuery('''
      SELECT 
        l.concept_id,
        l.display_text,
        l.part_of_speech
      FROM lexicon_fts fts
      JOIN lexicon l ON l.concept_id = fts.concept_id
      WHERE lexicon_fts MATCH ?
      LIMIT 20;
    ''', ['$query*']);
  }

  static Future<List<Map<String, dynamic>>> getExercises(String conceptId) async {
    if (_database == null) throw Exception('Database not initialized');

    return await _database!.query(
      'exercises',
      where: 'concept_id = ?',
      whereArgs: [conceptId],
    );
  }

  /// تطبيق خوارزمية التكرار المتباعد (SM-2) وتحديث جدول التقدم
  static Future<void> recordQuizResult({
    required String conceptId,
    required bool isCorrect,
  }) async {
    if (_database == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final records = await _database!.query(
      'user_progress',
      where: 'concept_id = ?',
      whereArgs: [conceptId],
    );

    int repetitions = 0;
    int boxLevel = 0;
    double easeFactor = 2.5;
    int intervalDays = 1;

    if (records.isNotEmpty) {
      final row = records.first;
      repetitions = (row['repetitions'] as int? ?? 0);
      boxLevel = (row['box_level'] as int? ?? 0);
      easeFactor = (row['ease_factor'] as num? ?? 2.5).toDouble();
      intervalDays = (row['interval_days'] as int? ?? 1);
    }

    if (isCorrect) {
      repetitions += 1;
      boxLevel += 1;
      if (repetitions == 1) {
        intervalDays = 1;
      } else if (repetitions == 2) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * easeFactor).round();
      }
      easeFactor = (easeFactor + 0.1).clamp(1.3, 3.0);
    } else {
      repetitions = 0;
      boxLevel = 0;
      intervalDays = 1;
      easeFactor = (easeFactor - 0.2).clamp(1.3, 3.0);
    }

    final nextReview = now + (intervalDays * 24 * 60 * 60 * 1000);

    await _database!.insert(
      'user_progress',
      {
        'concept_id': conceptId,
        'box_level': boxLevel,
        'ease_factor': easeFactor,
        'interval_days': intervalDays,
        'repetitions': repetitions,
        'last_reviewed_at': now,
        'next_review_at': nextReview,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// جلب البيانات الوصفية وحقوق الترخيص للعرض في التطبيق
  static Future<Map<String, String>> getDatasetMetadata() async {
    if (_database == null) return {};
    final rows = await _database!.query('dataset_metadata');
    return {for (var r in rows) r['key'] as String: r['value'] as String};
  }
}
