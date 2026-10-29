import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:deutsch_bilarabi/services/deck_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  late Database progress;
  late Database content;
  late Directory downloads;
  late DeckExportService service;

  setUp(() async {
    downloads = await Directory.systemTemp.createTemp('anki-export-test-');
    progress = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    content = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    await progress.execute(
      'CREATE TABLE srs_progress (lexeme_id TEXT PRIMARY KEY, '
      'target_language_code TEXT, next_due_at INTEGER)',
    );
    await content.execute(
      'CREATE TABLE lexicon (id TEXT PRIMARY KEY, surface TEXT, fields_json TEXT)',
    );
    await progress.insert('srs_progress', <String, Object?>{
      'lexeme_id': 'de-haus',
      'target_language_code': 'de',
      'next_due_at': 1000,
    });
    await content.insert('lexicon', <String, Object?>{
      'id': 'de-haus', 'surface': 'Haus',
      'fields_json': jsonEncode(<String, Object?>{'translation_ar': 'بيت'}),
    });
    service = DeckExportService(
      progressDb: () async => progress,
      contentDb: (_) async => content,
      downloadsDirectory: () async => downloads,
      temporaryDirectory: () async => downloads,
    );
  });

  tearDown(() async {
    await progress.close();
    await content.close();
    await downloads.delete(recursive: true);
  });

  test('tags words in local taxonomy and filters only recorded SRS words',
      () async {
    await service.tagWords(
      deckName: 'Travel', languageCode: 'de',
      lexemeIds: <String>['de-haus', 'de-missing', 'de-haus'],
    );
    final entries = await service.loadWords(deckName: 'Travel');
    expect(entries.map((e) => e.front), <String>['Haus']);
    expect(entries.single.back, 'بيت');
    expect(entries.single.tag, 'Travel');
  });

  test('CSV uses UTF-8 tab-separated Anki-import columns', () async {
    await service.tagWords(
      deckName: 'Medical', languageCode: 'de',
      lexemeIds: <String>['de-haus'],
    );
    final csv = await service.exportCsv(deckName: 'Medical');
    final data = await csv.readAsString(encoding: utf8);
    expect(data, contains('Front\tBack\tTags\n'));
    expect(data, contains('Haus\tبيت\tMedical\n'));
    expect(csv.path, endsWith('.csv'));
  });

  test('builds an APKG ZIP containing actual SQLite and media manifest',
      () async {
    await service.tagWords(
      deckName: 'Exam C1', languageCode: 'de',
      lexemeIds: <String>['de-haus'],
    );
    final apkg = await service.exportAnkiApkg(deckName: 'Exam C1');
    final contents = ZipDecoder().decodeBytes(await apkg.readAsBytes());
    expect(contents.files.map((f) => f.name),
        containsAll(<String>['collection.anki2', 'media']));
    final sqlite = contents.files.firstWhere(
      (file) => file.name == 'collection.anki2',
    ).content;
    expect(utf8.decode(sqlite.sublist(0, 16)), 'SQLite format 3\u0000');
    expect(apkg.path, endsWith('.apkg'));
  });

  test('filters future SRS reviews when dueOnly is requested', () async {
    await service.tagWords(
      deckName: 'Review', languageCode: 'de',
      lexemeIds: <String>['de-haus'],
    );
    final notDue = await service.loadWords(
      deckName: 'Review', dueOnly: true,
      now: DateTime.fromMillisecondsSinceEpoch(500000),
    );
    final due = await service.loadWords(
      deckName: 'Review', dueOnly: true,
      now: DateTime.fromMillisecondsSinceEpoch(1500000),
    );
    expect(notDue, isEmpty);
    expect(due.single.front, 'Haus');
  });

  test('rejects invalid taxonomy and limits', () async {
    expect(
      () => service.tagWords(
        deckName: ' ', languageCode: 'de', lexemeIds: <String>[],
      ),
      throwsArgumentError,
    );
    expect(
      () => service.loadWords(deckName: 'Travel', limit: 5001),
      throwsRangeError,
    );
  });
}
