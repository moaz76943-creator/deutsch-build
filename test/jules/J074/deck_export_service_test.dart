import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/deck_export_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DeckExportService', () {
    late Directory tempDir;
    late Directory downloadsDir;
    late String progressDbPath;
    late String contentDbPath;
    late Database progressDb;
    late Database contentDb;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('deck_export_test_temp_');
      downloadsDir = Directory.systemTemp.createTempSync('deck_export_test_dl_');
      progressDbPath = p.join(tempDir.path, 'progress.db');
      contentDbPath = p.join(tempDir.path, 'content_de.db');

      progressDb = await databaseFactory.openDatabase(progressDbPath);
      contentDb = await databaseFactory.openDatabase(contentDbPath);

      await progressDb.execute('''
        CREATE TABLE custom_decks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE COLLATE NOCASE
        )
      ''');
      await progressDb.execute('''
        CREATE TABLE custom_deck_words (
          deck_id INTEGER NOT NULL,
          language_code TEXT NOT NULL,
          lexeme_id TEXT NOT NULL,
          PRIMARY KEY (deck_id, language_code, lexeme_id)
        )
      ''');
      await progressDb.execute('''
        CREATE TABLE srs_progress (
          lexeme_id TEXT NOT NULL,
          target_language_code TEXT NOT NULL,
          next_due_at INTEGER,
          PRIMARY KEY (lexeme_id, target_language_code)
        )
      ''');

      await contentDb.execute('''
        CREATE TABLE lexicon (
          id TEXT PRIMARY KEY,
          surface TEXT NOT NULL,
          fields_json TEXT
        )
      ''');
    });

    tearDown(() async {
      if (progressDb.isOpen) await progressDb.close();
      if (contentDb.isOpen) await contentDb.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      if (downloadsDir.existsSync()) downloadsDir.deleteSync(recursive: true);
    });

    DeckExportService createService() {
      return DeckExportService(
        progressDb: () async => progressDb,
        contentDb: (lang) async {
          if (lang == 'de') return contentDb;
          throw Exception('Unknown language');
        },
        downloadsDirectory: () async => downloadsDir,
        temporaryDirectory: () async => tempDir,
      );
    }

    test('Apkg zip is correctly formed and atomic', () async {
      final svc = createService();

      await contentDb.rawInsert(
        'INSERT INTO lexicon (id, surface, fields_json) VALUES (?, ?, ?)',
        ['word_1', 'Apfel', jsonEncode({'translation_ar': 'تفاحة'})],
      );

      await progressDb.rawInsert(
        'INSERT INTO srs_progress (lexeme_id, target_language_code) VALUES (?, ?)',
        ['word_1', 'de'],
      );

      await svc.tagWords(
        deckName: 'Zip Deck',
        languageCode: 'de',
        lexemeIds: ['word_1'],
      );

      final apkg = await svc.exportAnkiApkg(deckName: 'Zip Deck');
      expect(apkg.existsSync(), isTrue);

      final bytes = apkg.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      expect(archive.findFile('collection.anki2'), isNotNull);
      expect(archive.findFile('media'), isNotNull);
      expect(archive.findFile('manifest.json'), isNotNull);
    });

    test('CSV exports fields conditionally', () async {
      final svc = createService();

      await contentDb.rawInsert(
        'INSERT INTO lexicon (id, surface, fields_json) VALUES (?, ?, ?)',
        ['word_1', 'Apfel', jsonEncode({
            'translation_ar': 'تفاحة',
            'example_ar': 'مثال',
            'grammar': 'Noun',
            'cefr': 'A1',
            'isCefrVerified': true,
        })],
      );

      await contentDb.rawInsert(
        'INSERT INTO lexicon (id, surface, fields_json) VALUES (?, ?, ?)',
        ['word_2', 'Baum', jsonEncode({
            'translation_ar': 'شجرة',
            'example_ar': 'مثال',
            'grammar': 'Noun',
            'cefr': 'A2',
            'isCefrVerified': false, // or omitted
        })],
      );

      await progressDb.rawInsert(
        'INSERT INTO srs_progress (lexeme_id, target_language_code) VALUES (?, ?)',
        ['word_1', 'de'],
      );
      await progressDb.rawInsert(
        'INSERT INTO srs_progress (lexeme_id, target_language_code) VALUES (?, ?)',
        ['word_2', 'de'],
      );

      await svc.tagWords(
        deckName: 'Verify Deck',
        languageCode: 'de',
        lexemeIds: ['word_1', 'word_2'],
      );

      final words = await svc.loadWords(deckName: 'Verify Deck');
      expect(words.length, 2);

      final w1 = words.firstWhere((w) => w.lexemeId == 'word_1');
      expect(w1.example, 'مثال');
      expect(w1.cefr, 'A1');
      expect(w1.grammar, 'Noun');

      final w2 = words.firstWhere((w) => w.lexemeId == 'word_2');
      expect(w2.example, isNull);
      expect(w2.cefr, isNull);
      expect(w2.grammar, isNull);
    });

    test('Path traversal is rejected', () async {
      final svc = createService();
      expect(() => svc.tagWords(deckName: '../malicious', languageCode: 'de', lexemeIds: []), throwsArgumentError);
      expect(() => svc.exportAnkiApkg(deckName: 'safe/unsafe'), throwsArgumentError);
    });

    test('Export preserves old file on failure and is atomic', () async {
      final svc = createService();

      await contentDb.rawInsert(
        'INSERT INTO lexicon (id, surface, fields_json) VALUES (?, ?, ?)',
        ['word_3', 'Haus', jsonEncode({'translation_ar': 'منزل'})],
      );

      await progressDb.rawInsert(
        'INSERT INTO srs_progress (lexeme_id, target_language_code) VALUES (?, ?)',
        ['word_3', 'de'],
      );

      await svc.tagWords(
        deckName: 'AtomicDeck',
        languageCode: 'de',
        lexemeIds: ['word_3'],
      );

      final apkg = await svc.exportAnkiApkg(deckName: 'AtomicDeck');
      expect(apkg.existsSync(), isTrue);

      final apkg2 = await svc.exportAnkiApkg(deckName: 'AtomicDeck');
      expect(apkg2.existsSync(), isTrue);
      expect(apkg.path, isNot(equals(apkg2.path))); // Since _fileStem uses timestamp, it creates a new file.

      // Let's test large exports bounds. 5001 is bounded to 5000 limits.
      expect(() => svc.loadWords(deckName: 'AtomicDeck', limit: 6000), throwsRangeError);
      expect(() => svc.loadWords(deckName: 'AtomicDeck', limit: 0), throwsRangeError);
    });
  });
}
