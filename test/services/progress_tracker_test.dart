import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/progress_tracker_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late ProgressTrackerService service;

  setUp(() async {
    // using an in-memory db specifically for testing so tests don't share state
    service = ProgressTrackerService.withFactory(databaseFactoryFfi);
    // Workaround since our singleton and withFactory doesn't allow easy re-init of different dbs.
    // Let's clear the database before each test.
    final db = await service.database;
    await db.execute('DELETE FROM completed_lessons');
    await db.execute('DELETE FROM daily_streaks');
    await db.execute('DELETE FROM review_scores');
    await db.execute('DELETE FROM spaced_repetition');
  });

  tearDown(() async {
    // keeping it open as it's a singleton and we clear it in setUp, but closing it at the very end is fine
    // wait, if we close it here it will recreate on next test.
    await service.close();
  });

  group('ProgressTrackerService', () {
    test('markLessonCompleted saves data and export includes it', () async {
      await service.markLessonCompleted('lesson_1');

      final jsonStr = await service.exportProgressState();
      final decoded = jsonDecode(jsonStr);

      final completedLessons = decoded['completed_lessons'] as List;
      expect(completedLessons.length, 1);
      expect(completedLessons[0]['id'], 'lesson_1');
      expect(completedLessons[0]['completedAt'], isNotNull);
    });

    test('updateStreak saves data and export includes it', () async {
      await service.updateStreak('2023-01-01', 5);

      final jsonStr = await service.exportProgressState();
      final decoded = jsonDecode(jsonStr);

      final streaks = decoded['daily_streaks'] as List;
      expect(streaks.length, 1);
      expect(streaks[0]['date'], '2023-01-01');
      expect(streaks[0]['count'], 5);
    });

    test('updateReviewScore saves data and export includes it', () async {
      await service.updateReviewScore('lesson_2', 95.5);

      final jsonStr = await service.exportProgressState();
      final decoded = jsonDecode(jsonStr);

      final reviewScores = decoded['review_scores'] as List;
      expect(reviewScores.length, 1);
      expect(reviewScores[0]['lessonId'], 'lesson_2');
      expect(reviewScores[0]['score'], 95.5);
      expect(reviewScores[0]['reviewedAt'], isNotNull);
    });

    test('importProgressState restores state properly', () async {
      final initialState = {
        'completed_lessons': [
          {'id': 'lesson_3', 'completedAt': '2023-05-05T12:00:00Z'},
        ],
        'daily_streaks': [
          {'date': '2023-05-05', 'count': 10},
        ],
        'review_scores': [
          {
            'lessonId': 'lesson_3',
            'score': 100.0,
            'reviewedAt': '2023-05-05T12:00:00Z',
          },
        ],
      };

      await service.importProgressState(jsonEncode(initialState));

      final exportedStr = await service.exportProgressState();
      final exported = jsonDecode(exportedStr);

      expect((exported['completed_lessons'] as List).length, 1);
      expect(exported['completed_lessons'][0]['id'], 'lesson_3');

      expect((exported['daily_streaks'] as List).length, 1);
      expect(exported['daily_streaks'][0]['count'], 10);

      expect((exported['review_scores'] as List).length, 1);
      expect(exported['review_scores'][0]['score'], 100.0);
    });
  });
}
