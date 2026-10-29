import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:deutsch_bilarabi/services/delta_patch_service.dart';
import 'package:deutsch_bilarabi/services/srs_scheduler_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Two independent SQLite files: content updates cannot erase learner SRS.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  late Directory sandbox;
  late File pack;
  late File progress;

  Future<Database> openFile(File file) =>
      databaseFactoryFfi.openDatabase(file.path,
          options: OpenDatabaseOptions(singleInstance: false));
  Future<String> digest(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('offline_storage_pair_');
    pack = File('${sandbox.path}/ar.sqlite');
    progress = File('${sandbox.path}/user_progress_v2.db');
    final content = await openFile(pack);
    try {
      await content.execute(
          'CREATE TABLE lexicon (id TEXT PRIMARY KEY, surface TEXT)');
      await content.insert('lexicon',
          <String, Object?>{'id': 'stable-id', 'surface': 'original'});
      await content.execute('PRAGMA user_version = 1');
    } finally {
      await content.close();
    }
    final learner = await openFile(progress);
    try {
      await learner.execute('''
        CREATE TABLE srs_progress (
          lexeme_id TEXT NOT NULL,
          target_language_code TEXT NOT NULL,
          repetition_count INTEGER NOT NULL DEFAULT 0,
          interval_days INTEGER NOT NULL DEFAULT 1,
          ease_factor REAL NOT NULL DEFAULT 2.5,
          next_due_at INTEGER,
          status TEXT NOT NULL DEFAULT 'learning',
          user_note TEXT,
          PRIMARY KEY (lexeme_id, target_language_code)
        )
      ''');
      await learner.insert('srs_progress', <String, Object?>{
        'lexeme_id': 'stable-id',
        'target_language_code': 'ar',
        'repetition_count': 2,
        'interval_days': 6,
        'ease_factor': 2.5,
        'next_due_at': 1791676800,
        'status': 'review',
        'user_note': 'preserve this learner note',
      });
    } finally {
      await learner.close();
    }
  });

  tearDown(() async {
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  test('invalid pack update leaves content and progress unchanged', () async {
    final oldPack = await digest(pack);
    final oldProgress = await digest(progress);
    await expectLater(
      DeltaPatchService(factory: databaseFactoryFfi).applyPatch(
        databaseFile: pack,
        patch: <String, dynamic>{
          'fromVersion': 1,
          'toVersion': 2,
          'expectedSha256': List<String>.filled(64, '0').join(),
          'operations': <Map<String, dynamic>>[
            <String, dynamic>{
              'op': 'update',
              'table': 'lexicon',
              'where': <String, Object?>{'id': 'stable-id'},
              'values': <String, Object?>{'surface': 'candidate'},
            },
          ],
        },
      ),
      throwsStateError,
    );
    expect(await digest(pack), oldPack);
    expect(await digest(progress), oldProgress);
    expect(await File('${pack.path}.delta-staging').exists(), isFalse);

    final content = await openFile(pack);
    try {
      expect((await content.query('lexicon')).single['surface'], 'original');
    } finally {
      await content.close();
    }
    final learner = await openFile(progress);
    try {
      final row = (await learner.query('srs_progress')).single;
      expect(row['repetition_count'], 2);
      expect(row['user_note'], 'preserve this learner note');
    } finally {
      await learner.close();
    }
  });

  test('successful learner review does not modify content pack', () async {
    final oldPack = await digest(pack);
    final learner = await openFile(progress);
    try {
      final result = await SrsSchedulerService().gradeAndPersist(
        progressDb: learner,
        lexemeId: 'stable-id',
        languageCode: 'ar',
        grade: 3,
        reviewedAt: DateTime.utc(2026, 10, 11),
      );
      expect(result.repetitionCount, 3);
      final row = (await learner.query('srs_progress')).single;
      expect(row['repetition_count'], 3);
      expect(row['user_note'], 'preserve this learner note');
    } finally {
      await learner.close();
    }
    expect(await digest(pack), oldPack);
  });
}
