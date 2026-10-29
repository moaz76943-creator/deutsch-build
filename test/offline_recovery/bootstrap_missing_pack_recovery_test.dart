import 'dart:io';

import 'package:deutsch_bilarabi/core/database/bootstrap/database_bootstrapper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Independent readiness checks for a device with no installed content packs.
/// Private Draft PR #131 already owns the related production fix.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory scratch;

  setUp(() async {
    scratch = await Directory.systemTemp.createTemp('offline_bootstrap_');
  });

  tearDown(() async {
    if (await scratch.exists()) {
      await scratch.delete(recursive: true);
    }
  });

  test('missing database without seeder stays NOT_READY', () async {
    final file = File('${scratch.path}/missing.sqlite');
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
    );
    expect(result.isReady, isFalse);
    expect(await file.exists(), isFalse);
  });

  test('seeder that completes without creating SQLite is NOT_READY',
      () async {
    final file = File('${scratch.path}/unseeded.sqlite');
    var seedCalls = 0;
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
      onSeedRequired: () async {
        seedCalls++;
        // Simulate an interrupted/incorrect first-install seed.
      },
    );

    // RED on staging base: verifyAndPrepare currently returns isReady=true
    // when a seeder returns normally but never creates the database file.
    expect(seedCalls, 1);
    expect(result.isReady, isFalse);
    expect(await file.exists(), isFalse);
  });

  test('interrupted seed with incomplete header does not become ready',
      () async {
    final file = File('${scratch.path}/truncated.sqlite');
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
      onSeedRequired: () async {
        await file.writeAsBytes(<int>[83, 81, 76, 105, 116, 101]);
      },
    );
    expect(result.isReady, isFalse);
    expect(await file.exists(), isTrue);
  });

  test('seeder exception is reported without removing existing data',
      () async {
    final file = File('${scratch.path}/unavailable.sqlite');
    final result = await DatabaseBootstrapper.verifyAndPrepare(
      dbPath: file.path,
      onSeedRequired: () async {
        throw const FileSystemException('simulated interrupted seed');
      },
    );
    expect(result.isReady, isFalse);
    expect(result.error, isNotNull);
  });
}
