import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:deutsch_bilarabi/core/storage/migration_journal.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'package:deutsch_bilarabi/core/srs_scheduler.dart';
import 'package:deutsch_bilarabi/services/srs_scheduler_service.dart';
import 'package:deutsch_bilarabi/services/fts_search_service.dart';
import 'package:deutsch_bilarabi/services/trie_search_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  group('MigrationJournal Defect Repair Tests', () {
    test('hasMigrated correctly recognizes recorded migration IDs', () {
      final journal = MigrationJournal();
      expect(journal.hasMigrated('v2_schema_migration'), isFalse);

      journal.recordMigration('v2_schema_migration');
      expect(journal.hasMigrated('v2_schema_migration'), isTrue);
      expect(journal.hasMigrated('v3_future_migration'), isFalse);

      final records = journal.history;
      expect(records, hasLength(1));
      expect(records.first.migrationId, 'v2_schema_migration');
      expect(records.first.timestampEpoch, greaterThan(0));
    });
  });

  group('SRS Scheduler Cognitive & Safety Enhancements', () {
    final scheduler = SrsSchedulerService();

    test('leech detection triggers on repeated failures of learned items', () {
      // Unlearned item failure: not a leech yet
      final firstFail = scheduler.calculate(
        grade: 0,
        previous: const SrsReviewState(repetitionCount: 0, intervalDays: 0, easeFactor: 2.5),
      );
      expect(firstFail.isLeech, isFalse);

      // Learned item with degraded ease factor failing again: marked as leech
      final leechFail = scheduler.calculate(
        grade: 1,
        previous: const SrsReviewState(repetitionCount: 3, intervalDays: 12, easeFactor: 1.4),
      );
      expect(leechFail.isLeech, isTrue);
      expect(leechFail.repetitionCount, 0);
      expect(leechFail.intervalDays, 1);
    });

    test('overdue review recovery accounts for demonstrated retention span', () {
      // Normal schedule: interval 6 * ease 2.5 = 15
      final normal = scheduler.calculate(
        grade: 3,
        previous: const SrsReviewState(repetitionCount: 2, intervalDays: 6, easeFactor: 2.5),
        elapsedDays: 6,
      );
      expect(normal.intervalDays, 15);

      // Overdue schedule: learner remembered after 30 days (much longer than 6 days)
      final recovered = scheduler.calculate(
        grade: 3,
        previous: const SrsReviewState(repetitionCount: 2, intervalDays: 6, easeFactor: 2.5),
        elapsedDays: 30,
      );
      // Effective interval factors in fraction of extra elapsed retention
      expect(recovered.intervalDays, greaterThan(normal.intervalDays));
      expect(recovered.repetitionCount, 3);
    });

    test('circadian day rollover aligns next review to 4:00 AM boundary', () {
      final reviewTime = DateTime.utc(2026, 10, 15, 23, 45); // 11:45 PM
      final result = scheduler.calculate(
        grade: 3,
        previous: const SrsReviewState(repetitionCount: 0, intervalDays: 0, easeFactor: 2.5),
        reviewedAt: reviewTime,
        alignToCircadianDay: true,
        rolloverHour: 4,
      );

      final nextDate = DateTime.fromMillisecondsSinceEpoch(result.nextReviewEpoch * 1000, isUtc: true);
      expect(nextDate.hour, 4);
      expect(nextDate.minute, 0);
      expect(nextDate.day, 16); // Next day at 4 AM
    });

    test('gradeFromResponseTime scores rapid recall as Easy and sluggish recall as Hard', () {
      expect(
        SrsSchedulerService.gradeFromResponseTime(isCorrect: false, responseTime: const Duration(seconds: 1)),
        0, // Again
      );
      expect(
        SrsSchedulerService.gradeFromResponseTime(isCorrect: true, responseTime: const Duration(seconds: 2)),
        4, // Easy
      );
      expect(
        SrsSchedulerService.gradeFromResponseTime(isCorrect: true, responseTime: const Duration(seconds: 6)),
        3, // Good
      );
      expect(
        SrsSchedulerService.gradeFromResponseTime(isCorrect: true, responseTime: const Duration(seconds: 14)),
        2, // Hard
      );
    });
  });

  group('SQLite Idempotency & Language-Pair Isolation', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      await db.execute('''
        CREATE TABLE srs_progress (
          lexeme_id TEXT NOT NULL,
          target_language_code TEXT NOT NULL,
          repetition_count INTEGER NOT NULL DEFAULT 0,
          interval_days INTEGER NOT NULL DEFAULT 1,
          ease_factor REAL NOT NULL DEFAULT 2.5,
          next_due_at INTEGER,
          status TEXT NOT NULL DEFAULT 'learning',
          PRIMARY KEY (lexeme_id, target_language_code)
        )
      ''');
      await db.execute('''
        CREATE INDEX idx_srs_due_covering
        ON srs_progress(target_language_code, next_due_at, lexeme_id)
      ''');
      await db.execute('''
        CREATE TABLE srs_review_events (
          review_event_id TEXT PRIMARY KEY,
          lexeme_id TEXT NOT NULL,
          target_language_code TEXT NOT NULL,
          grade INTEGER NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
    });

    tearDown(() async {
      if (db.isOpen) await db.close();
    });

    test('idempotent reviewEventId prevents double-reviews and duplicate writes', () async {
      final scheduler = SrsSchedulerService();

      // First review
      final first = await scheduler.gradeAndPersist(
        progressDb: db,
        lexemeId: 'card-101',
        languageCode: 'de',
        grade: 3,
        reviewEventId: 'EVT_001',
        reviewedAt: DateTime.utc(2026, 10, 15, 10, 0),
      );
      expect(first.repetitionCount, 1);
      expect(first.intervalDays, 1);

      // Duplicate submission of exact same review event ID (e.g. rapid double tap)
      final duplicate = await scheduler.gradeAndPersist(
        progressDb: db,
        lexemeId: 'card-101',
        languageCode: 'de',
        grade: 3,
        reviewEventId: 'EVT_001',
        reviewedAt: DateTime.utc(2026, 10, 15, 10, 0),
      );

      // Must remain at repetitionCount = 1, NOT advance to 2!
      expect(duplicate.repetitionCount, 1);
      expect(duplicate.intervalDays, 1);

      final row = await db.query(
        'srs_progress',
        where: 'lexeme_id = ? AND target_language_code = ?',
        whereArgs: ['card-101', 'de'],
      );
      expect(row.single['repetition_count'], 1);

      // Verify only 1 review event record exists
      final events = await db.query('srs_review_events', where: 'review_event_id = ?', whereArgs: ['EVT_001']);
      expect(events, hasLength(1));
    });

    test('directed language-pair isolation preserves independent progress', () async {
      final scheduler = SrsSchedulerService();

      // Review card-202 for German
      await scheduler.gradeAndPersist(
        progressDb: db,
        lexemeId: 'card-202',
        languageCode: 'de',
        grade: 3,
        reviewEventId: 'EVT_DE',
      );

      // Review same lexeme card-202 for Arabic
      await scheduler.gradeAndPersist(
        progressDb: db,
        lexemeId: 'card-202',
        languageCode: 'ar',
        grade: 4,
        reviewEventId: 'EVT_AR',
      );

      final deRow = (await db.query(
        'srs_progress',
        where: 'lexeme_id = ? AND target_language_code = ?',
        whereArgs: ['card-202', 'de'],
      )).single;

      final arRow = (await db.query(
        'srs_progress',
        where: 'lexeme_id = ? AND target_language_code = ?',
        whereArgs: ['card-202', 'ar'],
      )).single;

      expect(deRow['target_language_code'], 'de');
      expect(deRow['repetition_count'], 1);

      expect(arRow['target_language_code'], 'ar');
      expect(arRow['repetition_count'], 1);
      expect((arRow['ease_factor'] as num).toDouble(), greaterThan((deRow['ease_factor'] as num).toDouble()));
    });
  });

  group('Multilingual Search, Umlauts, Diacritics, and Short Queries', () {
    test('TrieSearchEngine normalizes German umlauts and sharp s', () {
      expect(TrieSearchEngine.normalizeForLanguage('Äpfel', 'de'), 'aepfel');
      expect(TrieSearchEngine.normalizeForLanguage('Schloß', 'de'), 'schloss');
      expect(TrieSearchEngine.normalizeForLanguage('Über', 'de'), 'ueber');
      expect(TrieSearchEngine.normalizeForLanguage('Können', 'de'), 'koennen');
    });

    test('TrieSearchEngine strips Arabic harakat diacritics', () {
      const vocalized = 'مُعَلِّمٌ';
      final stripped = TrieSearchEngine.normalizeForLanguage(vocalized, 'ar');
      expect(stripped, 'معلم');
    });

    test('FtsSearchService handles short queries with prefix scan without error', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      try {
        await db.execute('''
          CREATE TABLE lexicon (
            id TEXT PRIMARY KEY,
            surface TEXT NOT NULL,
            part_of_speech TEXT,
            fields_json TEXT,
            language_code TEXT NOT NULL
          )
        ''');
        await db.insert('lexicon', {
          'id': 'de-01',
          'surface': 'ab',
          'part_of_speech': 'prep',
          'fields_json': '{}',
          'language_code': 'de',
        });
        await db.insert('lexicon', {
          'id': 'de-02',
          'surface': 'aber',
          'part_of_speech': 'conj',
          'fields_json': '{}',
          'language_code': 'de',
        });

        final service = FtsSearchService();
        final results = await service.searchDatabase(db, 'ab', languageCode: 'de');
        expect(results, isNotEmpty);
        expect(results.any((r) => r['surface'] == 'ab'), isTrue);
      } finally {
        await db.close();
      }
    });
  });
}
