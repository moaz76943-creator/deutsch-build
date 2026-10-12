import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive.dart';

class PackManager {
  static Database? _database;
  static String? _currentLanguage;

  /// تهيئة حزمة اللغة وفك ضغطها محلياً إذا لم تكن موجودة
  static Future<Database> initLanguagePack(String langCode) async {
    if (_database != null && _currentLanguage == langCode) {
      return _database!;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docsDir.path, '$langCode-1.0.0.sqlite');

    if (!await File(dbPath).exists()) {
      final assetPath = 'assets/content/packs/$langCode/$langCode-1.0.0.pack.gz';
      final byteData = await rootBundle.load(assetPath);
      final compressedBytes = byteData.buffer.asUint8List();

      final decompressedBytes = GZipDecoder().decodeBytes(compressedBytes);
      await File(dbPath).writeAsBytes(decompressedBytes, flush: true);
    }

    _database = await openDatabase(dbPath, readOnly: false);
    _currentLanguage = langCode;
    return _database!;
  }

  /// جلب المفاهيم حسب القسم والمستوى التعليمي (أقل من 3 مللي ثانية)
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
        l.plural
      FROM concepts c
      JOIN lexicon l ON l.concept_id = c.concept_id
      WHERE c.section_id = ? AND c.cefr = ?;
    ''', [sectionId, cefr]);
  }

  /// بحث لحظي فائق السرعة عبر محرك FTS5
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

  /// جلب التمارين المدمجة لمفهوم محدد
  static Future<List<Map<String, dynamic>>> getExercises(String conceptId) async {
    if (_database == null) throw Exception('Database not initialized');

    return await _database!.query(
      'exercises',
      where: 'concept_id = ?',
      whereArgs: [conceptId],
    );
  }
}
