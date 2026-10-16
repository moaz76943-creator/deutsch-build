import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

/// Synthetic content probes: not a corpus, published pack, or rights receipt.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ffi.sqfliteFfiInit);

  late Database db;

  setUp(() async {
    db = await ffi.databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE lexicon (
        id TEXT PRIMARY KEY,
        language_code TEXT NOT NULL,
        surface TEXT NOT NULL,
        part_of_speech TEXT NOT NULL,
        fields_json TEXT NOT NULL
      )
    ''');
    for (final row in <List<String>>[
      ['lex.de.1', 'de', 'Haus'],
      ['lex.ar.1', 'ar', 'بيت'],
      ['lex.ja.1', 'ja', '家'],
      ['lex.ko.1', 'ko', '집'],
      ['lex.ar.2', 'ar', 'مدرسة'],
    ]) {
      await db.insert('lexicon', <String, Object?>{
        'id': row[0],
        'language_code': row[1],
        'surface': row[2],
        'part_of_speech': 'noun',
        'fields_json': '{}',
      });
    }
  });

  tearDown(() => db.close());

  test('due card IDs from another language are never relabeled as Arabic', () async {
    final rows = await DatabaseService.queryDueFlashcardRows(
      db, 'ar', <String>['lex.de.1', 'lex.ar.1', 'lex.ja.1'],
    );
    expect(rows.map((r) => r['id']).toList(), <String>['lex.ar.1']);
  });

  test('new flashcard pages are isolated before OFFSET is applied', () async {
    final first = await DatabaseService.queryFlashcardPage(
      db, 'ar', limit: 1, offset: 0,
    );
    final second = await DatabaseService.queryFlashcardPage(
      db, 'ar', limit: 1, offset: 1,
    );
    final third = await DatabaseService.queryFlashcardPage(
      db, 'ar', limit: 1, offset: 2,
    );
    expect(first.single['surface'], 'بيت');
    expect(second.single['surface'], 'مدرسة');
    expect(third, isEmpty);
  });

  test('CJK and German card pages preserve exact language identity', () async {
    for (final code in <String>['de', 'ja', 'ko']) {
      final rows = await DatabaseService.queryFlashcardPage(
        db, code, limit: 10, offset: 0,
      );
      expect(rows, hasLength(1), reason: code);
      expect(rows.single['id'].toString(), startsWith('lex.$code.'));
    }
  });

  test('empty due queue stays empty even when another language exists', () async {
    expect(
      await DatabaseService.queryDueFlashcardRows(db, 'ar', <String>[]),
      isEmpty,
    );
    expect(
      await DatabaseService.queryDueFlashcardRows(
        db, 'ar', <String>['lex.de.1'],
      ),
      isEmpty,
    );
  });

  test('bound the batch size and prevent excessive materialization', () async {
    expect(
      () => DatabaseService.queryFlashcardPage(
        db, 'ar', limit: 10000, offset: 0,
      ),
      throwsRangeError,
    );
  });
}
