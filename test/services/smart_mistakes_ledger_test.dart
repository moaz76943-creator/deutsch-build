import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/smart_mistakes_ledger.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await SmartMistakesLedger.instance.database;
    await db.delete('smart_mistakes');
  });

  tearDownAll(() async {
    await SmartMistakesLedger.instance.close();
  });

  test('logMistake inserts a new record when word is not present', () async {
    final timestamp = DateTime(2023, 10, 15, 12, 0, 0);
    await SmartMistakesLedger.instance.logMistake('word1', 'Again', timestamp);

    final difficultWords = await SmartMistakesLedger.instance
        .getDifficultWords();
    expect(difficultWords.length, 1);
    expect(difficultWords.first['word_id'], 'word1');
    expect(difficultWords.first['rating'], 'Again');
    expect(difficultWords.first['mistake_count'], 1);
    expect(difficultWords.first['timestamp'], timestamp.toIso8601String());
  });

  test(
    'logMistake updates mistake count and details when word is already present',
    () async {
      final timestamp1 = DateTime(2023, 10, 15, 12, 0, 0);
      await SmartMistakesLedger.instance.logMistake(
        'word2',
        'Again',
        timestamp1,
      );

      final timestamp2 = DateTime(2023, 10, 16, 12, 0, 0);
      await SmartMistakesLedger.instance.logMistake(
        'word2',
        'Hard',
        timestamp2,
      );

      final difficultWords = await SmartMistakesLedger.instance
          .getDifficultWords();
      expect(difficultWords.length, 1);
      expect(difficultWords.first['word_id'], 'word2');
      expect(difficultWords.first['rating'], 'Hard');
      expect(difficultWords.first['mistake_count'], 2);
      expect(difficultWords.first['timestamp'], timestamp2.toIso8601String());
    },
  );

  test(
    'getDifficultWords orders by count descending then timestamp descending',
    () async {
      final t1 = DateTime(2023, 10, 1, 10, 0, 0);
      final t2 = DateTime(2023, 10, 2, 10, 0, 0);
      final t3 = DateTime(2023, 10, 3, 10, 0, 0);

      // wordA: 1 mistake
      await SmartMistakesLedger.instance.logMistake('wordA', 'Hard', t1);
      // wordB: 2 mistakes
      await SmartMistakesLedger.instance.logMistake('wordB', 'Again', t1);
      await SmartMistakesLedger.instance.logMistake('wordB', 'Again', t2);
      // wordC: 1 mistake, but more recent than wordA
      await SmartMistakesLedger.instance.logMistake('wordC', 'Again', t3);

      final difficultWords = await SmartMistakesLedger.instance
          .getDifficultWords();
      expect(difficultWords.length, 3);

      // 1st: wordB (2 mistakes)
      expect(difficultWords[0]['word_id'], 'wordB');
      // 2nd: wordC (1 mistake, more recent)
      expect(difficultWords[1]['word_id'], 'wordC');
      // 3rd: wordA (1 mistake, older)
      expect(difficultWords[2]['word_id'], 'wordA');
    },
  );
}
