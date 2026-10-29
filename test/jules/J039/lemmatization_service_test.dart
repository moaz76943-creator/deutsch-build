import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/lemmatization_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LemmatizationService Tests', () {
    late LemmatizationService service;
    late Database db;
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('lemmatization_test_');
      final dbPath = '${tempDir.path}/test.db';
      db = await databaseFactory.openDatabase(dbPath, options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE inflections_lookup (
            inflected_form TEXT NOT NULL,
            language_code TEXT NOT NULL,
            lemma TEXT NOT NULL,
            lexicon_id TEXT
          )
        ''');
        await db.execute("INSERT INTO inflections_lookup VALUES ('Wasser', 'de', 'Wasser', 'lex1')");
        await db.execute("INSERT INTO inflections_lookup VALUES ('Bücher', 'de', 'Buch', 'lex2')");
        await db.execute("INSERT INTO inflections_lookup VALUES ('gegangen', 'de', 'gehen', 'lex3')");
        await db.execute("INSERT INTO inflections_lookup VALUES ('kitaplar', 'tr', 'kitap', 'lex4')");
        await db.execute("INSERT INTO inflections_lookup VALUES ('kataba', 'ar', 'kataba1', 'lex5')");
        await db.execute("INSERT INTO inflections_lookup VALUES ('kataba', 'ar', 'kataba2', 'lex6')");
        await db.execute("INSERT INTO inflections_lookup VALUES ('貓們', 'zh', '貓', 'lex7')"); // CJK forms
      }));
      service = LemmatizationService(openContentDb: (code) async => db);
    });

    tearDown(() async {
        await db.close();
        if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
        }
    });

    test('lookup resolves exact match from lemma (German)', () async {
      final results = await service.lookup('Wasser', languageCode: 'de');
      expect(results.length, 1);
      expect(results.first.lemma, 'Wasser');
    });

    test('lookup resolves from plural (German)', () async {
      final results = await service.lookup('Bücher', languageCode: 'de');
      expect(results.length, 1);
      expect(results.first.lemma, 'Buch');
    });

    test('lookup resolves from Turkish suffix form', () async {
      final results = await service.lookup('kitaplar', languageCode: 'tr');
      expect(results.length, 1);
      expect(results.first.lemma, 'kitap');
    });

    test('lookup resolves CJK form', () async {
      final results = await service.lookup('貓們', languageCode: 'zh');
      expect(results.length, 1);
      expect(results.first.lemma, '貓');
    });

    test('lookup returns empty for unknown word', () async {
      final results = await service.lookup('UnknownWord', languageCode: 'de');
      expect(results.isEmpty, true);
    });

    test('resolve returns single unambiguous lemma', () async {
      final result = await service.resolve('gegangen', languageCode: 'de');
      expect(result, 'gehen');
    });

    test('resolve returns null for ambiguous lemma (Hebrew/Arabic)', () async {
      final result = await service.resolve('kataba', languageCode: 'ar');
      expect(result, null);
    });

  });
}
