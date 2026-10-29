import 'dart:io';

import 'package:deutsch_bilarabi/core/services/progress_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _DocumentsPathProvider extends PathProviderPlatform {
  _DocumentsPathProvider(this.documents);
  final String documents;

  @override
  Future<String?> getApplicationDocumentsPath() async => documents;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory documents;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    documents = await Directory.systemTemp.createTemp('learner-progress-');
    PathProviderPlatform.instance = _DocumentsPathProvider(documents.path);
  });

  tearDownAll(() async {
    if (documents.existsSync()) {
      await documents.delete(recursive: true);
    }
  });

  Future<Map<String, Object?>> row(String conceptId) async {
    final db = await openDatabase(
      path.join(documents.path, 'user_progress.sqlite'),
    );
    final rows = await db.query(
      'user_progress',
      where: 'concept_id = ?',
      whereArgs: <Object>[conceptId],
    );
    return rows.single;
  }

  test('empty concept ids are rejected before any write', () async {
    expect(
      () => ProgressDatabaseService.recordProgress(
        conceptId: '   ',
        isCorrect: true,
      ),
      throwsArgumentError,
    );
  });

  test('a wrong answer keeps the row and does not touch another concept', () async {
    await ProgressDatabaseService.recordProgress(
      conceptId: 'der-Hund',
      isCorrect: true,
    );
    await ProgressDatabaseService.recordProgress(
      conceptId: 'die-Katze',
      isCorrect: true,
    );
    await ProgressDatabaseService.recordProgress(
      conceptId: 'der-Hund',
      isCorrect: false,
    );

    final hund = await row('der-Hund');
    final katze = await row('die-Katze');
    expect(hund['repetitions'], 0);
    expect(hund['box_level'], 0);
    expect(hund['interval_days'], 1);
    expect(hund['last_reviewed_at'], isNotNull);
    expect(katze['repetitions'], 1);
    expect(katze['box_level'], 1);

    final levels = await ProgressDatabaseService.getAllBoxLevels();
    expect(levels['der-Hund'], 0);
    expect(levels['die-Katze'], 1);
  });

  test('correct reviews follow the SM-2 intervals and clamp ease', () async {
    const id = 'das-Haus';
    await ProgressDatabaseService.recordProgress(conceptId: id, isCorrect: true);
    expect((await row(id))['interval_days'], 1);
    expect((await row(id))['ease_factor'], closeTo(2.6, 0.001));

    await ProgressDatabaseService.recordProgress(conceptId: id, isCorrect: true);
    expect((await row(id))['interval_days'], 6);
    expect((await row(id))['repetitions'], 2);

    await ProgressDatabaseService.recordProgress(conceptId: id, isCorrect: true);
    expect((await row(id))['interval_days'], 16);
    expect((await row(id))['ease_factor'], closeTo(2.8, 0.001));

    for (var i = 0; i < 30; i++) {
      await ProgressDatabaseService.recordProgress(
        conceptId: id,
        isCorrect: false,
      );
    }
    final floor = await row(id);
    expect(floor['ease_factor'], closeTo(1.3, 0.001));
    expect(floor['concept_id'], id);

    for (var i = 0; i < 30; i++) {
      await ProgressDatabaseService.recordProgress(
        conceptId: id,
        isCorrect: true,
      );
    }
    expect((await row(id))['ease_factor'], closeTo(3.0, 0.001));
  });
}
