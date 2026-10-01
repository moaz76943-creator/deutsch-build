import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/features/reverse_quiz_mode/reverse_quiz_mode.dart';
import 'package:deutsch_bilarabi/features/reverse_quiz_mode/data/database.dart';
import 'package:deutsch_bilarabi/features/reverse_quiz_mode/domain/models.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ReverseQuizMode Tests', () {
    late ReverseQuizDatabase database;
    late ReverseQuizMode reverseQuizMode;

    setUp(() async {
      database = ReverseQuizDatabase(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
      reverseQuizMode = ReverseQuizMode(database);
    });

    tearDown(() async {
      await reverseQuizMode.close();
    });

    test('should insert and randomly fetch flashcards', () async {
      final items = [
        const ReverseQuizItem(id: '1', conceptId: 'c1', german: 'Hallo', arabic: 'مرحبا'),
        const ReverseQuizItem(id: '2', conceptId: 'c2', german: 'Welt', arabic: 'عالم'),
        const ReverseQuizItem(id: '3', conceptId: 'c3', german: 'Buch', arabic: 'كتاب'),
      ];

      await reverseQuizMode.initialize(items);

      final randomItems = await reverseQuizMode.fetchQuizItems(2);

      expect(randomItems.length, 2);
      final itemIds = randomItems.map((e) => e.id).toSet();
      expect(itemIds.intersection({'1', '2', '3'}).length, 2);
    });

    test('should record attempts correctly', () async {
      final items = [
        const ReverseQuizItem(id: '1', conceptId: 'c1', german: 'Hallo', arabic: 'مرحبا'),
      ];

      await reverseQuizMode.initialize(items);

      await reverseQuizMode.submitAnswer('1', true);
      await reverseQuizMode.submitAnswer('1', false);

      final db = await database.database;
      final attempts = await db.query('quiz_attempts');

      expect(attempts.length, 2);
      expect(attempts[0]['cardId'], '1');
      expect(attempts[0]['isCorrect'], 1);
      expect(attempts[1]['cardId'], '1');
      expect(attempts[1]['isCorrect'], 0);
    });
  });
}
