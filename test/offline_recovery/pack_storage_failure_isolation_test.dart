import 'dart:io';

import 'package:deutsch_bilarabi/services/storage_migration_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

/// Failure-injection tests for moving immutable packs between app-private
/// directories. No learner database, system storage or Android permissions.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory sandbox;
  late Directory sourceDir;
  late Directory externalRoot;

  StorageMigrationService service({
    Future<void> Function(String)? closeContentDb,
    Future<int?> Function(Directory)? freeSpaceProbe,
  }) {
    return StorageMigrationService(
      internalDirectory: () async => sourceDir,
      externalDirectories: () async => <Directory>[externalRoot],
      androidPlatform: true,
      closeContentDb: closeContentDb ?? (_) async {},
      freeSpaceProbe: freeSpaceProbe ?? (_) async => 1024 * 1024,
    );
  }

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('offline_migration_');
    sourceDir = Directory(path.join(sandbox.path, 'internal'));
    externalRoot = Directory(path.join(sandbox.path, 'external'));
    await sourceDir.create(recursive: true);
  });

  tearDown(() async {
    if (await sandbox.exists()) {
      await sandbox.delete(recursive: true);
    }
  });

  test('open SQLite close failure leaves original pack unchanged', () async {
    final installed = File(path.join(sourceDir.path, 'fr.sqlite'));
    const original = <int>[1, 2, 3, 4, 5, 6, 7];
    await installed.writeAsBytes(original);
    var closeCalls = 0;
    final mover = service(
      closeContentDb: (_) async {
        closeCalls++;
        throw StateError('simulated open SQLite connection');
      },
    );
    final location = (await mover.availableLocations()).last;

    await expectLater(
      mover.migratePack('fr.sqlite', destination: location),
      throwsStateError,
    );
    expect(closeCalls, 1);
    expect(await installed.readAsBytes(), orderedEquals(original));
    expect(
      await File(path.join(location.directory.path, 'fr.sqlite')).exists(),
      isFalse,
    );
  });

  test('an abandoned staging file blocks overwrite and preserves both files',
      () async {
    final installed = File(path.join(sourceDir.path, 'es.pack.gz'));
    const original = <int>[10, 20, 30, 40];
    await installed.writeAsBytes(original);

    final mover = service();
    final location = (await mover.availableLocations()).last;
    await location.directory.create(recursive: true);
    final staging = File(
      path.join(location.directory.path, 'es.pack.gz.migrating'),
    );
    const leftover = <int>[99, 98, 97];
    await staging.writeAsBytes(leftover);

    await expectLater(
      mover.migratePack('es.pack.gz', destination: location),
      throwsStateError,
    );
    expect(await installed.readAsBytes(), orderedEquals(original));
    expect(await staging.readAsBytes(), orderedEquals(leftover));
    expect(
      await File(path.join(location.directory.path, 'es.pack.gz')).exists(),
      isFalse,
    );
  });

  test('unknown target capacity is not treated as unlimited free space',
      () async {
    final installed = File(path.join(sourceDir.path, 'it.sqlite'));
    const original = <int>[22, 23, 24, 25];
    await installed.writeAsBytes(original);

    final mover = service(freeSpaceProbe: (_) async => null);
    final location = (await mover.availableLocations()).last;
    await expectLater(
      mover.migratePack('it.sqlite', destination: location),
      throwsStateError,
    );
    expect(await installed.readAsBytes(), orderedEquals(original));
    expect(
      await File(path.join(location.directory.path, 'it.sqlite')).exists(),
      isFalse,
    );
  });

  test('conflicting destination pack cannot destroy original or destination',
      () async {
    final installed = File(path.join(sourceDir.path, 'tr.sqlite'));
    const original = <int>[1, 3, 5, 7];
    await installed.writeAsBytes(original);
    final mover = service();
    final location = (await mover.availableLocations()).last;
    await location.directory.create(recursive: true);
    final destination = File(path.join(location.directory.path, 'tr.sqlite'));
    const existing = <int>[2, 4, 6, 8];
    await destination.writeAsBytes(existing);

    await expectLater(
      mover.migratePack('tr.sqlite', destination: location),
      throwsStateError,
    );
    expect(await installed.readAsBytes(), orderedEquals(original));
    expect(await destination.readAsBytes(), orderedEquals(existing));
  });
}
