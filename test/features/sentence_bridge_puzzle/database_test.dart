import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/features/sentence_bridge_puzzle/data/database.dart';
import 'package:deutsch_bilarabi/features/sentence_bridge_puzzle/domain/models.dart';

void main() {
  late SentenceBridgeDatabase database;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    database = SentenceBridgeDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('Database initialization works', () async {
    final db = await database.database;
    expect(db.isOpen, true);
  });

  test('Insert and retrieve puzzles works', () async {
    final puzzlesToInsert = [
      PuzzleItem(
        id: 'p1',
        conceptId: 'c1',
        germanSentence: 'Ich lerne Deutsch.',
        arabicSentence: 'أنا أتعلم الألمانية.',
      ).toMap(),
      PuzzleItem(
        id: 'p2',
        conceptId: 'c2',
        germanSentence: 'Das Wetter ist schön.',
        arabicSentence: 'الطقس جميل.',
      ).toMap(),
    ];

    await database.insertPuzzles(puzzlesToInsert);

    final retrieved = await database.getRandomPuzzles(1);
    expect(retrieved.length, 1);

    final item = retrieved.first;
    expect(item['id'] == 'p1' || item['id'] == 'p2', true);
    expect(item['germanSentence'] != null, true);
    expect(item['arabicSentence'] != null, true);
  });

  test('Record attempt works', () async {
    final puzzlesToInsert = [
      PuzzleItem(
        id: 'p1',
        conceptId: 'c1',
        germanSentence: 'Ich lerne Deutsch.',
        arabicSentence: 'أنا أتعلم الألمانية.',
      ).toMap(),
    ];
    await database.insertPuzzles(puzzlesToInsert);

    final attempt = PuzzleAttempt(
      id: 'a1',
      puzzleId: 'p1',
      isCorrect: true,
      timestamp: DateTime.now(),
      timeTakenMs: 1500,
    );

    await database.recordAttempt(attempt.toMap());

    // Verify it was inserted by querying the db directly
    final db = await database.database;
    final results = await db.query('puzzle_attempts');
    expect(results.length, 1);
    expect(results.first['id'], 'a1');
    expect(results.first['puzzleId'], 'p1');
    expect(results.first['isCorrect'], 1);
  });
}
