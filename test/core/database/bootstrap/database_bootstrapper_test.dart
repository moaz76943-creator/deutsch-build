import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/database/bootstrap/database_bootstrapper.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('db_bootstrap_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('يرفض الملفات التالفة أو التي لا تحتوي ترويسة SQLite', () async {
    final corruptFile = File('${tempDir.path}/corrupt.db');
    await corruptFile.writeAsString('Fake non-sqlite content');

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: corruptFile.path,
    );

    expect(result.isReady, isFalse);
    expect(result.error, contains('Invalid SQLite header signature'));
  });

  test('يقبل الملف السليم الذي يبدأ بترويسة SQLite format 3', () async {
    final validFile = File('${tempDir.path}/valid.db');
    final headerBytes = 'SQLite format 3\x00'.codeUnits;
    await validFile.writeAsBytes(headerBytes);

    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: validFile.path,
    );

    expect(result.isReady, isTrue);
    expect(result.error, isNull);
  });

  test('seeder must create a file before SQLite bootstrap reports ready', () async {
    final missingPath = '${tempDir.path}/seed_did_nothing.sqlite';
    var seedCalls = 0;
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: missingPath,
      onSeedRequired: () async { seedCalls++; },
    );

    expect(seedCalls, 1);
    expect(result.isReady, isFalse);
    expect(result.error, contains('still missing after seeding'));
    expect(await File(missingPath).exists(), isFalse);
  });

  test('newly seeded SQLite file proceeds through header verification', () async {
    final seededPath = '${tempDir.path}/seeded.sqlite';
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: seededPath,
      onSeedRequired: () async {
        await File(seededPath).writeAsBytes('SQLite format 3\x00'.codeUnits);
      },
    );

    expect(result.isReady, isTrue);
    expect(result.error, isNull);
  });
}
