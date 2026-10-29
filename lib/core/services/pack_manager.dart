import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:sqflite/sqflite.dart';
import '../../services/database_service.dart';

/// Read-only language pack queries. DatabaseService owns all database handles.
class PackManager {
  static final DatabaseService _dbService = DatabaseService.instance;
  static String? _activeLanguageCode;

  // An omitted language only resolves after the user selects a pack.
  static String _language(String? languageCode) {
    final selection = languageCode ?? _activeLanguageCode;
    if (selection == null) {
      throw StateError('No active content language has been selected');
    }
    final code = selection.trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(code)) {
      throw ArgumentError.value(selection, 'languageCode');
    }
    return code.split('-').first == 'de' ? 'de' : code;
  }

  static Future<void> initLanguagePack(
    String langCode, {
    void Function(double progress)? onDownloadProgress,
  }) async {
    final code = _language(langCode);
    // Keep the requested selection if a pack is missing; do not show German.
    _activeLanguageCode = code;
    await _dbService.withContentDb<void>(code, (db) async {});
    onDownloadProgress?.call(1.0);
  }

  static Future<List<Map<String, dynamic>>> getConceptsBySection({
    required String sectionId,
    required String cefr,
    String? languageCode,
  }) async {
    final code = _language(languageCode);
    return _dbService.withContentDb<List<Map<String, dynamic>>>(
      code, (db) => queryConceptsBySectionFromDb(
        db, sectionId: sectionId, cefr: cefr, languageCode: code,
      ),
    );
  }

  /// Canonical SQLite v2: lexicon.cefr_level, senses.payload_json.
  /// concepts has only concept_id, not cefr or semantic_tags_json.
  @visibleForTesting
  static Future<List<Map<String, dynamic>>> queryConceptsBySectionFromDb(
    Database db, {
    required String sectionId,
    required String cefr,
    required String languageCode,
    int limit = 50,
  }) async {
    final code = _language(languageCode);
    if (limit < 1 || limit > 50) {
      throw RangeError.range(limit, 1, 50, 'limit');
    }
    final section = sectionId.trim();
    final level = cefr.trim().toUpperCase();
    if (section.isEmpty || level.isEmpty) return <Map<String, dynamic>>[];
    final rows = await db.rawQuery('''
      SELECT DISTINCT s.concept_id, l.id AS lexeme_id, l.surface AS word,
        l.part_of_speech, l.fields_json, l.sort_key
      FROM senses AS s
      JOIN lexicon AS l ON l.id = s.lexeme_id
      WHERE l.language_code = ? AND l.cefr_level = ?
        AND (
          EXISTS (SELECT 1 FROM json_each(s.payload_json, '\$.semantic_tags')
                  WHERE value = ?)
          OR EXISTS (SELECT 1 FROM json_each(s.payload_json, '\$.domains')
                     WHERE value = ?)
        )
      ORDER BY l.sort_key, l.id, s.concept_id LIMIT ?
    ''', <Object?>[code, level, section, section, limit]);

    return rows.map((row) {
      final fields = jsonDecode(row['fields_json']?.toString() ?? '{}');
      final morphology = fields is Map ? fields['morphology'] : null;
      String? plural;
      if (morphology is Map && morphology['inflections'] is List) {
        for (final inflection in morphology['inflections'] as List) {
          if (inflection is! Map || inflection['features'] is! Map) continue;
          final features = inflection['features'] as Map;
          if (features['number'] == 'plural' &&
              inflection['attested'] == true &&
              inflection['surface'] is String) {
            plural = inflection['surface'] as String;
            break;
          }
        }
      }
      return <String, dynamic>{
        'concept_id': row['concept_id'],
        'lexeme_id': row['lexeme_id'],
        'language_code': code,
        'word': row['word'],
        'display_text': row['word'],
        'part_of_speech': row['part_of_speech'],
        'gender': morphology is Map ? morphology['gender'] : null,
        'plural': plural,
      };
    }).toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> searchInstant(
    String query, {String? languageCode}
  ) => _dbService.searchDictionary(
    query, _language(languageCode), limit: 20,
  );

  /// Missing optional quiz tables are not synthesized from example sentences.
  static Future<List<Map<String, dynamic>>> getExercises(
    String conceptId, {String? languageCode, int limit = 12}
  ) async {
    final code = _language(languageCode);
    return _dbService.withContentDb<List<Map<String, dynamic>>>(
      code, (db) => queryExercisesFromDb(
        db, conceptId: conceptId, languageCode: code, limit: limit,
      ),
    );
  }

  @visibleForTesting
  static Future<List<Map<String, dynamic>>> queryExercisesFromDb(
    Database db, {
    required String conceptId,
    required String languageCode,
    int limit = 12,
  }) async {
    final code = _language(languageCode);
    if (limit < 1 || limit > 50) {
      throw RangeError.range(limit, 1, 50, 'limit');
    }
    if (conceptId.trim().isEmpty) return <Map<String, dynamic>>[];
    final table = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name = 'exercises' LIMIT 1",
    );
    if (table.isEmpty) return <Map<String, dynamic>>[];
    final columns = (await db.rawQuery('PRAGMA table_info(exercises)'))
        .map((row) => row['name']).whereType<String>().toSet();
    const required = <String>{
      'concept_id', 'language_code', 'prompt',
      'correct_answer', 'distractors_json',
    };
    if (!columns.containsAll(required)) {
      throw StateError('Incompatible optional exercises table');
    }
    final order = columns.contains('exercise_id')
        ? 'exercise_id' : 'prompt, correct_answer';
    final rows = await db.rawQuery(
      'SELECT prompt, correct_answer, distractors_json FROM exercises '
      'WHERE concept_id = ? AND language_code = ? '
      'ORDER BY $order LIMIT ?',
      <Object?>[conceptId, code, limit],
    );
    for (final row in rows) {
      if (row['prompt'] is! String || row['correct_answer'] is! String ||
          row['distractors_json'] is! String ||
          (row['prompt'] as String).trim().isEmpty ||
          (row['correct_answer'] as String).trim().isEmpty) {
        throw const FormatException('Malformed exercise');
      }
      final distractors = jsonDecode(row['distractors_json'] as String);
      if (distractors is! List ||
          distractors.any((item) => item is! String)) {
        throw const FormatException('Malformed exercise distractors');
      }
    }
    return rows.map((r) => Map<String, dynamic>.from(r)).toList(growable: false);
  }

  /// Resolve stable lexeme identity before recording a concept-level quiz.
  @visibleForTesting
  static Future<String?> resolveLexemeIdForConcept(
    Database db, {
    required String conceptId,
    required String languageCode,
  }) async {
    final code = _language(languageCode);
    // Use explicit lexeme identity whenever provided by the caller.
    final direct = await db.rawQuery(
      'SELECT id FROM lexicon WHERE id = ? AND language_code = ? LIMIT 1',
      <Object?>[conceptId, code],
    );
    if (direct.isNotEmpty) return direct.first['id']?.toString();
    // Ambiguous concepts must never modify an arbitrary learner SRS row.
    final matches = await db.rawQuery('''
      SELECT DISTINCT l.id FROM lexicon AS l
      JOIN senses AS s ON s.lexeme_id = l.id
      WHERE s.concept_id = ? AND l.language_code = ?
      ORDER BY l.id LIMIT 2
    ''', <Object?>[conceptId, code]);
    if (matches.length > 1) {
      throw StateError('Ambiguous concept: a lexeme ID is required');
    }
    return matches.isEmpty ? null : matches.single['id']?.toString();
  }

  static Future<void> recordQuizResult({
    required String conceptId,
    required bool isCorrect,
    String? languageCode,
  }) async {
    final code = _language(languageCode);
    final lexemeId = await _dbService.withContentDb<String?>(
      code, (db) => resolveLexemeIdForConcept(
        db, conceptId: conceptId, languageCode: code,
      ),
    );
    if (lexemeId == null) {
      throw StateError('No language-matched lexeme for quiz result');
    }
    await _dbService.gradeAndPersistSrs(
      lexemeId: lexemeId,
      languageCode: code,
      grade: isCorrect ? 4 : 0,
    );
  }

  static Future<Map<String, String>> getDatasetMetadata({
    String? languageCode,
  }) async {
    final code = _language(languageCode);
    return _dbService.withContentDb<Map<String, String>>(code, (db) async {
      final rows = await db.query('metadata', columns: ['key', 'value']);
      return <String, String>{
        for (final row in rows) row['key'].toString(): row['value'].toString(),
      };
    });
  }

  /// Keeps the caller's signature but never claims a file was written.
  static Future<String> exportDatasetAsJson(String langCode) async {
    _language(langCode);
    throw UnsupportedError(
      'Dataset JSON export is unavailable; no file was created.',
    );
  }
}
