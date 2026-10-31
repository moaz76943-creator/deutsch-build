import 'dart:convert';

import 'package:deutsch_bilarabi/core/storage/local_db/learner_state_database.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/learner_state_migration.dart';
import 'package:deutsch_bilarabi/services/legacy_learner_snapshot_reader.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migration verifies exact SHA and reruns idempotently', () async {
    final payload = jsonEncode(_legacyPayload());
    const legacyFavorites = <String>['lernen'];
    SharedPreferences.setMockInitialValues(<String, Object>{
      LearnerRepository.key: payload,
      LearnerRepository.legacyFavoriteKey: legacyFavorites,
    });
    final prefs = await PreferencesService.instance();

    sqfliteFfiInit();
    final rawDatabase =
        await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final database = await LearnerStateDatabase.attach(rawDatabase);
    addTearDown(database.close);

    final reader = LegacyLearnerSnapshotReader(
      prefs: prefs,
      storageKey: LearnerRepository.key,
      legacyFavoriteKey: LearnerRepository.legacyFavoriteKey,
    );
    final source = await reader.readStrict();
    final migration = LearnerStateMigration(
      database: database,
      legacyReader: reader,
      now: () => DateTime.utc(2026, 10, 7),
    );

    final first = await migration.migrateAndVerify();
    expect(first.status, LearnerStateMigrationStatus.migrated);
    expect(
      first.record.importedSnapshotSha256,
      source.canonicalSnapshotSha256,
    );

    final imported = await database.readSnapshot();
    expect(
      await LegacyLearnerSnapshotReader.canonicalSnapshotSha256(imported),
      source.canonicalSnapshotSha256,
    );
    expect(imported.attempts.length, 1);
    expect(imported.assessmentHistory.length, 1);
    expect(imported.placementHistory.length, 1);
    expect(imported.favoriteVerbs, <String>{'gehen', 'lernen'});

    final second = await migration.migrateAndVerify();
    expect(second.status, LearnerStateMigrationStatus.alreadyVerified);
    expect(
      second.record.importedSnapshotSha256,
      first.record.importedSnapshotSha256,
    );

    expect(prefs.getString(LearnerRepository.key), payload);
    expect(
      prefs.getStringList(LearnerRepository.legacyFavoriteKey),
      legacyFavorites,
    );
  });

  test('cutover SHA mismatch fails closed before revision advances', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      LearnerRepository.key: jsonEncode(_legacyPayload()),
    });
    final prefs = await PreferencesService.instance();

    sqfliteFfiInit();
    final rawDatabase =
        await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final database = await LearnerStateDatabase.attach(rawDatabase);
    addTearDown(database.close);

    final migration = LearnerStateMigration(
      database: database,
      legacyReader: LegacyLearnerSnapshotReader(
        prefs: prefs,
        storageKey: LearnerRepository.key,
        legacyFavoriteKey: LearnerRepository.legacyFavoriteKey,
      ),
    );
    await migration.migrateAndVerify();
    expect(await database.loadRevision(), 0);

    await rawDatabase.update(
      LearnerStateDatabase.attemptsTable,
      <String, Object?>{'answer': 'tampered'},
      where: 'attempt_id = ?',
      whereArgs: <Object?>['a_legacy_1'],
    );

    await expectLater(
      migration.migrateAndVerify(),
      throwsA(
        isA<LearnerStateMigrationException>().having(
          (error) => error.code,
          'code',
          'learner_sqlite_readback_mismatch',
        ),
      ),
    );
    expect(await migration.canFallbackToLegacy(), isFalse);
  });

  test('interrupted import rolls back and a later migration recovers', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      LearnerRepository.key: jsonEncode(_legacyPayload()),
    });
    final prefs = await PreferencesService.instance();

    sqfliteFfiInit();
    final rawDatabase =
        await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final database = await LearnerStateDatabase.attach(rawDatabase);
    addTearDown(database.close);

    final reader = LegacyLearnerSnapshotReader(
      prefs: prefs,
      storageKey: LearnerRepository.key,
      legacyFavoriteKey: LearnerRepository.legacyFavoriteKey,
    );
    final source = await reader.readStrict();

    await expectLater(
      database.transaction<void>((txn) async {
        await database.importSnapshot(txn, source.sqliteSnapshot);
        throw StateError('simulated_crash');
      }),
      throwsStateError,
    );

    expect(await database.hasDomainRows(), isFalse);
    expect(await database.loadRevision(), 0);
    expect(
      await database.loadMigrationRecord(
        LearnerStateMigration.migrationId,
      ),
      isNull,
    );

    final migration = LearnerStateMigration(
      database: database,
      legacyReader: reader,
    );
    final recovered = await migration.migrateAndVerify();
    expect(recovered.status, LearnerStateMigrationStatus.migrated);
    expect(
      recovered.record.importedSnapshotSha256,
      source.canonicalSnapshotSha256,
    );
  });

  test('verified cutover rejects stale legacy fallback after revision advances',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      LearnerRepository.key: jsonEncode(_legacyPayload()),
      LearnerRepository.legacyFavoriteKey: const <String>['lernen'],
    });
    final prefs = await PreferencesService.instance();

    sqfliteFfiInit();
    final rawDatabase =
        await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final database = await LearnerStateDatabase.attach(rawDatabase);

    final reader = LegacyLearnerSnapshotReader(
      prefs: prefs,
      storageKey: LearnerRepository.key,
      legacyFavoriteKey: LearnerRepository.legacyFavoriteKey,
    );
    final migration = LearnerStateMigration(
      database: database,
      legacyReader: reader,
    );
    final migrated = await migration.migrateAndVerify();

    final persistence = LearnerPersistence(
      prefs,
      LearnerRepository.key,
      LearnerRepository.legacyFavoriteKey,
    );
    await persistence.bindVerifiedSqliteAuthority(
      database: database,
      migrationRecord: migrated.record,
    );
    addTearDown(persistence.close);

    expect(await persistence.canUseLegacyRollbackBuffer(), isTrue);
    expect(persistence.load().favoriteVerbs, <String>{'gehen', 'lernen'});

    await persistence.setFavoriteMembership(
      'fahren',
      isFavorite: true,
    );

    final revision = await database.loadRevision();
    expect(revision, greaterThan(migrated.record.cutoverRevision));
    expect(await persistence.canUseLegacyRollbackBuffer(), isFalse);
    expect(
      persistence.load().favoriteVerbs,
      <String>{'gehen', 'lernen', 'fahren'},
    );

    final rerun = await migration.migrateAndVerify();
    expect(rerun.status, LearnerStateMigrationStatus.alreadyVerified);
  });

  test('duplicate legacy IDs fail closed and leave SQLite pristine', () async {
    final invalid = _legacyPayload();
    invalid['attempts'] = <Object?>[
      ...(invalid['attempts']! as List<Object?>),
      Map<String, Object?>.from(
        (invalid['attempts']! as List<Object?>).first
            as Map<String, Object?>,
      ),
    ];
    SharedPreferences.setMockInitialValues(<String, Object>{
      LearnerRepository.key: jsonEncode(invalid),
    });
    final prefs = await PreferencesService.instance();

    sqfliteFfiInit();
    final rawDatabase =
        await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final database = await LearnerStateDatabase.attach(rawDatabase);
    addTearDown(database.close);

    final migration = LearnerStateMigration(
      database: database,
      legacyReader: LegacyLearnerSnapshotReader(
        prefs: prefs,
        storageKey: LearnerRepository.key,
        legacyFavoriteKey: LearnerRepository.legacyFavoriteKey,
      ),
    );

    await expectLater(
      migration.migrateAndVerify(),
      throwsA(
        isA<LegacyLearnerSnapshotException>().having(
          (error) => error.code,
          'code',
          'duplicate_attempt_id',
        ),
      ),
    );

    expect(await database.hasDomainRows(), isFalse);
    expect(
      await database.loadMigrationRecord(
        LearnerStateMigration.migrationId,
      ),
      isNull,
    );
    expect(await database.loadRevision(), 0);
    expect(await migration.canFallbackToLegacy(), isTrue);
  });
}

Map<String, Object?> _legacyPayload() => <String, Object?>{
      'xp': 120,
      'streak': 4,
      'learned': <String>[],
      'review': <String>[],
      'reviewCards': <String, Object?>{},
      'favoriteVerbs': <String>['gehen'],
      'attempts': <Object?>[
        <String, Object?>{
          'id': 'a_legacy_1',
          'itemId': 'haus',
          'skill': 'recall',
          'answer': 'Haus',
          'correct': true,
          'hinted': false,
          'seconds': 4,
          'at': '2026-10-06T10:00:00.000Z',
          'facetType': 'meaning_recall',
        },
      ],
      'assessmentHistory': <Object?>[
        <String, Object?>{
          'id': 'assessment_1',
          'at': '2026-10-06T11:00:00.000Z',
          'score': 80.0,
          'weakSkills': <String>['grammar'],
          'answered': 10,
        },
      ],
      'placementHistory': <Object?>[
        <String, Object?>{
          'id': 'placement_1',
          'at': '2026-10-06T09:00:00.000Z',
          'answered': 10,
          'scoredAnswers': 10,
          'score': 70.0,
          'confidence': 0.8,
          'band': 'developing',
          'dimensionScores': <String, double>{
            'meaning': 0.8,
          },
          'weakDimensions': <String>['grammar'],
          'reviewItemIds': <String>['haus'],
          'curriculumStartLevel': 'A2',
          'recommendedStartTaskOrder': 12,
          'learningGoal': 'general',
        },
      ],
      'updatedAt': '2026-10-06T12:00:00.000Z',
    };
