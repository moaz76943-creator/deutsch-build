import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

/// استخراج بايتات SQLite الحقيقية سواء كانت مباشرة أو مغلفة داخل JSON Envelope
Uint8List _decompressAndExtractSqlite(Uint8List compressedBytes) {
  final decompressed = GZipDecoder().decodeBytes(compressedBytes);
  
  // فحص ترويسة SQLite القياسية (Header: SQLite format 3\000)
  const sqliteHeader = [83, 81, 76, 105, 116, 101, 32, 102, 111, 114, 109, 97, 116, 32, 51, 0];
  bool isRawSqlite = true;
  if (decompressed.length >= 16) {
    for (int i = 0; i < 16; i++) {
      if (decompressed[i] != sqliteHeader[i]) {
        isRawSqlite = false;
        break;
      }
    }
  } else {
    isRawSqlite = false;
  }

  if (isRawSqlite) {
    return Uint8List.fromList(decompressed);
  }

  // إذا لم تكن خام، محاولة فك غلاف JSON المستخرج من أدوات الـ ingestion
  try {
    final jsonStr = utf8.decode(decompressed);
    final decoded = jsonDecode(jsonStr);
    if (decoded is Map && decoded.containsKey('files')) {
      final files = decoded['files'] as List;
      for (final item in files) {
        if (item is Map && item['path'] == 'content/content.sqlite') {
          final base64Content = item['contentBase64'] as String;
          return base64Decode(base64Content);
        }
      }
    }
  } catch (_) {
    // في حال تعذر قراءة JSON، رمي خطأ صريح
  }

  throw const FormatException('صيغة الحزمة غير صالحة ولا تحتوي على ترويسة SQLite صالحة.');
}

class PackManager {
  static Database? _database;
  static String? _currentLanguage;
  static const String releaseBaseUrl = 
      'https://github.com/moaz76943-creator/deutsch-build/releases/download/v3.0.0';

  static Future<Database> initLanguagePack(
    String langCode, {
    void Function(double progress)? onDownloadProgress,
  }) async {
    if (_database != null && _currentLanguage == langCode) {
      return _database!;
    }

    if (_database != null) {
      await _database!.close();
      _database = null;
      _currentLanguage = null;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docsDir.path, '$langCode-1.0.0.sqlite');

    if (!await File(dbPath).exists()) {
      Uint8List? compressedBytes;

      try {
        final assetPath = 'assets/content/packs/$langCode/$langCode-1.0.0.pack.gz';
        final byteData = await rootBundle.load(assetPath);
        compressedBytes = byteData.buffer.asUint8List();
        onDownloadProgress?.call(1.0);
      } catch (_) {
        compressedBytes = null;
      }

      if (compressedBytes == null) {
        final client = http.Client();
        final request = http.Request('GET', Uri.parse('$releaseBaseUrl/$langCode-1.0.0.pack.gz'));
        final response = await client.send(request);

        if (response.statusCode != 200) {
          client.close();
          throw Exception('تعذر تحميل الحزمة من الخادم (كود الخطأ: ${response.statusCode})');
        }

        final totalBytes = response.contentLength ?? 0;
        final List<int> downloadedChunks = [];
        int receivedBytes = 0;

        await for (final chunk in response.stream) {
          downloadedChunks.addAll(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0 && onDownloadProgress != null) {
            onDownloadProgress(receivedBytes / totalBytes);
          }
        }
        client.close();
        compressedBytes = Uint8List.fromList(downloadedChunks);
      }

      // استخراج البايتات في Isolate مستقل والتحقق من الترويسة
      final sqliteBytes = await compute(_decompressAndExtractSqlite, compressedBytes);
      final tempDbPath = join(docsDir.path, '$langCode-temp.sqlite');
      
      final tempFile = File(tempDbPath);
      await tempFile.writeAsBytes(sqliteBytes, flush: true);
      await tempFile.rename(dbPath);
    }

    _database = await openDatabase(
      dbPath,
      readOnly: false,
      onConfigure: (db) async {
        await db.execute('PRAGMA busy_timeout = 5000;');
      },
    );
    _currentLanguage = langCode;
    return _database!;
  }

  static Future<List<Map<String, dynamic>>> getConceptsBySection({
    required String sectionId,
    required String cefr,
  }) async {
    if (_database == null) throw Exception('قاعدة البيانات غير مهيأة');

    // استعلام مرن يتوافق مع كلا المخططين (v1 و v2)
    return await _database!.rawQuery('''
      SELECT 
        c.concept_id,
        COALESCE(l.display_text, l.lemma, 'بدون عنوان') AS word,
        COALESCE(l.part_of_speech, 'noun') AS part_of_speech,
        l.gender,
        l.plural,
        COALESCE(up.box_level, 0) AS box_level
      FROM concepts c
      LEFT JOIN lexicon l ON l.concept_id = c.concept_id
      LEFT JOIN user_progress up ON up.concept_id = c.concept_id
      WHERE c.section_id = ? AND c.cefr = ?;
    ''', [sectionId, cefr]);
  }

  static Future<List<Map<String, dynamic>>> searchInstant(String query) async {
    if (_database == null) throw Exception('قاعدة البيانات غير مهيأة');

    return await _database!.rawQuery('''
      SELECT 
        l.concept_id,
        COALESCE(l.display_text, l.lemma) AS display_text,
        COALESCE(l.part_of_speech, 'noun') AS part_of_speech
      FROM lexicon_fts fts
      JOIN lexicon l ON l.concept_id = fts.concept_id
      WHERE lexicon_fts MATCH ?
      LIMIT 20;
    ''', ['$query*']);
  }

  static Future<List<Map<String, dynamic>>> getExercises(String conceptId) async {
    if (_database == null) throw Exception('قاعدة البيانات غير مهيأة');

    return await _database!.query(
      'exercises',
      where: 'concept_id = ?',
      whereArgs: [conceptId],
    );
  }

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
      intervalDays = (repetitions == 1) ? 1 : ((repetitions == 2) ? 6 : (intervalDays * easeFactor).round());
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

  static Future<Map<String, String>> getDatasetMetadata() async {
    if (_database == null) return {};
    try {
      final rows = await _database!.query('dataset_metadata');
      return {for (var r in rows) r['key'] as String: r['value'] as String};
    } catch (_) {
      return {'source': 'Local Fallback', 'license': 'CC BY-SA 4.0'};
    }
  }

  static Future<String> exportDatasetAsJson(String langCode) async {
    if (_database == null) throw Exception('قاعدة البيانات غير مهيأة');

    final concepts = await _database!.query('concepts');
    final lexicon = await _database!.query('lexicon');
    final metadata = await getDatasetMetadata();

    final exportBundle = {
      'metadata': metadata,
      'exported_at': DateTime.now().toIso8601String(),
      'concepts_count': concepts.length,
      'concepts': concepts,
      'lexicon': lexicon,
    };

    final docsDir = await getApplicationDocumentsDirectory();
    final exportFile = File(join(docsDir.path, 'export_${langCode}_dataset.json'));
    await exportFile.writeAsString(jsonEncode(exportBundle), flush: true);

    return exportFile.path;
  }
}
