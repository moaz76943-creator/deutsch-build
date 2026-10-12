import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../services/database_service.dart';

class PackManager {
  static final DatabaseService _dbService = DatabaseService.instance;

  static Future<void> initLanguagePack(
    String langCode, {
    void Function(double progress)? onDownloadProgress,
  }) async {
    onDownloadProgress?.call(1.0);
    // التحقق من إمكانية فتح القاعدة
    await _dbService.withContentDb(langCode, (db) async => true);
  }

  static Future<List<Map<String, dynamic>>> getConceptsBySection({
    required String sectionId,
    required String cefr,
    String languageCode = 'de',
  }) async {
    return await _dbService.withContentDb<List<Map<String, dynamic>>>(
      languageCode,
      (Database db) async {
        final rows = await db.rawQuery('''
          SELECT
            c.concept_id,
            x.display_text AS word,
            x.part_of_speech,
            x.gender,
            x.plural
          FROM concepts c
          INNER JOIN lexemes x ON x.concept_id = c.concept_id
          WHERE c.cefr = ?
            AND EXISTS (
              SELECT 1 FROM json_each(c.semantic_tags_json) tag
              WHERE tag.value = ?
            )
          ORDER BY x.display_text;
        ''', [cefr, sectionId]);

        return rows.map((r) => Map<String, dynamic>.from(r)).toList();
      },
    );
  }

  static Future<List<Map<String, dynamic>>> searchInstant(
    String query, {
    String languageCode = 'de',
  }) async {
    return await _dbService.searchDictionary(query, languageCode, limit: 20);
  }

  static Future<void> recordQuizResult({
    required String conceptId,
    required bool isCorrect,
    String languageCode = 'de',
  }) async {
    await _dbService.gradeAndPersistSrs(
      lexemeId: conceptId,
      langCode: languageCode,
      isCorrect: isCorrect,
    );
  }

  static Future<Map<String, String>> getDatasetMetadata({String languageCode = 'de'}) async {
    return await _dbService.withContentDb(languageCode, (db) async {
      final rows = await db.query('metadata');
      return {for (var r in rows) r['key'] as String: r['value'] as String};
    });
  }

  static Future<String> exportDatasetAsJson(String langCode) async {
    return 'export_\${langCode}_dataset.json';
  }
}
