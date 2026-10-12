import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'progress_database_service.dart';

Uint8List _decompressAndExtractSqlite(Uint8List compressedBytes) {
  final decompressed = GZipDecoder().decodeBytes(compressedBytes);
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

  try {
    final jsonStr = utf8.decode(decompressed);
    final decoded = jsonDecode(jsonStr);
    if (decoded is Map && decoded.containsKey('files')) {
      final files = decoded['files'] as List;
      for (final item in files) {
        if (item is Map && item['path'] == 'content/content.sqlite') {
          return base64Decode(item['contentBase64'] as String);
        }
      }
    }
  } catch (_) {}

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

      final sqliteBytes = await compute(_decompressAndExtractSqlite, compressedBytes);
      final tempDbPath = join(docsDir.path, '$langCode-temp.sqlite');
      
      final tempFile = File(tempDbPath);
      await tempFile.writeAsBytes(sqliteBytes, flush: true);
      await tempFile.rename(dbPath);
    }

    // فتح قاعدة المحتوى في وضع القراءة فقط للحماية المطلقة
    _database = await openDatabase(
      dbPath,
      readOnly: true,
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

    final conceptsData = await _database!.rawQuery('''
      SELECT 
        c.concept_id,
        COALESCE(l.display_text, l.lemma, 'بدون عنوان') AS word,
        COALESCE(l.part_of_speech, 'noun') AS part_of_speech,
        l.gender,
        l.plural
      FROM concepts c
      LEFT JOIN lexicon l ON l.concept_id = c.concept_id
      WHERE c.section_id = ? AND c.cefr = ?;
    ''', [sectionId, cefr]);

    // دمج تقدم الحفظ من قاعدة البيانات المستقلة
    final boxLevels = await ProgressDatabaseService.getAllBoxLevels();

    return conceptsData.map((row) {
      final cid = row['concept_id'] as String;
      final mutable = Map<String, dynamic>.from(row);
      mutable['box_level'] = boxLevels[cid] ?? 0;
      return mutable;
    }).toList();
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
    await ProgressDatabaseService.recordProgress(
      conceptId: conceptId,
      isCorrect: isCorrect,
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
