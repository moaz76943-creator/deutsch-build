import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:deutsch_bilarabi/services/storage_migration_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late Directory internal;
  late Directory sd;
  late StorageMigrationService service;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('pack_migration_');
    internal = Directory(path.join(temp.path, 'internal'));
    sd = Directory(path.join(temp.path, 'sd', 'deutsch_packs'));
    await internal.create(recursive: true);
    service = StorageMigrationService(
      internalDirectory: () async => internal,
      externalDirectories: () async => <Directory>[
        Directory(path.join(temp.path, 'emulated')),
        Directory(path.dirname(sd.path)),
      ],
      androidPlatform: true,
      freeSpaceProbe: (_) async => 1024 * 1024,
      closeContentDb: (_) async {},
    );
  });

  tearDown(() async {
    await temp.delete(recursive: true);
  });

  test('detects primary external storage and removable SD separately',
      () async {
    final locations = await service.availableLocations();
    expect(locations, hasLength(3));
    expect(locations.first.isExternal, isFalse);
    expect(locations[1].isRemovable, isFalse);
    expect(locations.last.isRemovable, isTrue);
  });

  test('rejects traversal and unknown pack extensions', () async {
    expect(() => service.resolvePackPath('../x.sqlite'),
        throwsArgumentError);
    expect(() => service.resolvePackPath('secret.txt'),
        throwsArgumentError);
  });

  test('pre-existing internal packs resolve without migration', () async {
    final pack = File(path.join(internal.path, 'en.sqlite'));
    await pack.writeAsBytes(<int>[1, 2, 3]);
    expect(await service.resolvePackPath('en.sqlite'), pack.path);
  });

  test('atomic SHA-256 migration preserves bytes and removes source',
      () async {
    final source = File(path.join(internal.path, 'fr.pack.gz'));
    await source.writeAsBytes(List<int>.generate(4096, (i) => i % 256));
    final digest = await sha256.bind(source.openRead()).first;
    final sdVolume = (await service.availableLocations()).last;
    final migrated = await service.migratePack(
      'fr.pack.gz', destination: sdVolume,
    );
    expect(await source.exists(), isFalse);
    expect(await migrated.exists(), isTrue);
    expect(await sha256.bind(migrated.openRead()).first, digest);
    expect(await service.resolvePackPath('fr.pack.gz'), migrated.path);
  });

  test('insufficient free space never deletes the original file', () async {
    final source = File(path.join(internal.path, 'de.sqlite'));
    await source.writeAsBytes(List<int>.filled(100, 42));
    final limited = StorageMigrationService(
      internalDirectory: () async => internal,
      externalDirectories: () async =>
          <Directory>[Directory(path.dirname(sd.path))],
      androidPlatform: true,
      freeSpaceProbe: (_) async => 10,
      closeContentDb: (_) async {},
    );
    final target = (await limited.availableLocations()).last;
    await expectLater(
      limited.migratePack('de.sqlite', destination: target),
      throwsStateError,
    );
    expect(await source.exists(), isTrue);
    expect(await File(path.join(target.directory.path, 'de.sqlite')).exists(),
        isFalse);
  });

  test('symlinked external pack directory is never a migration target',
      () async {
    if (Platform.isWindows) return;
    final outside = Directory(path.join(temp.path, 'outside'));
    await outside.create(recursive: true);
    await Directory(path.dirname(sd.path)).create(recursive: true);
    await Link(sd.path).create(outside.path);

    final locations = await service.availableLocations();
    expect(
      locations.where((item) => item.directory.path == sd.absolute.path),
      isEmpty,
    );

    final source = File(path.join(internal.path, 'it.sqlite'));
    await source.writeAsBytes(<int>[1, 2, 3, 4]);
    await expectLater(
      service.migratePack(
        'it.sqlite',
        destination: PackStorageLocation(
          directory: sd,
          isExternal: true,
          isRemovable: true,
        ),
      ),
      throwsArgumentError,
    );
    expect(await source.readAsBytes(), <int>[1, 2, 3, 4]);
    expect(await Directory(outside.path).list().toList(), isEmpty);
  });

  test('conflicting target cannot overwrite an existing pack', () async {
    final source = File(path.join(internal.path, 'es.sqlite'));
    await source.writeAsBytes(<int>[1, 2, 3]);
    final target = (await service.availableLocations()).last;
    await target.directory.create(recursive: true);
    final conflict = File(path.join(target.directory.path, 'es.sqlite'));
    await conflict.writeAsBytes(<int>[7, 8, 9]);
    await expectLater(
      service.migratePack('es.sqlite', destination: target),
      throwsStateError,
    );
    expect(await source.readAsBytes(), <int>[1, 2, 3]);
    expect(await conflict.readAsBytes(), <int>[7, 8, 9]);
  });
}
