import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/providers/active_language_provider.dart';

void main() {
  late Directory root;
  late LanguagePackStorage storage;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('atomic_archive_test_');
    storage = LanguagePackStorage();
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<File> targetWithOldPack() async {
    final target = File('${root.path}/ar.pack.gz');
    await target.writeAsBytes(<int>[1, 2, 3, 4]);
    return target;
  }

  test('verified staged archive atomically replaces the previous archive',
      () async {
    final target = await targetWithOldPack();
    final staging = await root.createTemp('.ar-');
    final staged = File('${staging.path}/ar.pack.gz');
    final bytes = <int>[9, 8, 7, 6, 5];
    await staged.writeAsBytes(bytes);

    await storage.promoteVerifiedArchive(
      stagedFile: staged,
      targetFile: target,
      expectedSize: bytes.length,
      expectedHash: sha256.convert(bytes).toString(),
    );

    expect(await target.readAsBytes(), bytes);
    expect(await staged.exists(), isFalse);
  });

  test('incorrect hash cannot replace last-known-good archive', () async {
    final target = await targetWithOldPack();
    final staged = File('${root.path}/untrusted.pack.gz');
    await staged.writeAsBytes(<int>[9, 9, 9]);

    await expectLater(
      storage.promoteVerifiedArchive(
        stagedFile: staged,
        targetFile: target,
        expectedSize: 3,
        expectedHash: sha256.convert(<int>[1, 1, 1]).toString(),
      ),
      throwsFormatException,
    );
    expect(await target.readAsBytes(), <int>[1, 2, 3, 4]);
    expect(await staged.exists(), isTrue);
  });

  test('staged symlink to old archive cannot destroy last-known-good',
      () async {
    if (Platform.isWindows) return; // Android/POSIX rename regression.
    final target = await targetWithOldPack();
    final staged = Link('${root.path}/stage.pack.gz');
    await staged.create(target.path);
    final oldBytes = await target.readAsBytes();

    await expectLater(
      storage.promoteVerifiedArchive(
        stagedFile: File(staged.path),
        targetFile: target,
        expectedSize: oldBytes.length,
        expectedHash: sha256.convert(oldBytes).toString(),
      ),
      throwsFormatException,
    );
    expect(await target.readAsBytes(), oldBytes);
    expect(await staged.exists(), isTrue);
  });

  test('symlinked destination cannot be treated as a managed archive',
      () async {
    if (Platform.isWindows) return;
    final outside = File('${root.path}/unmanaged.db');
    final original = <int>[4, 3, 2, 1];
    await outside.writeAsBytes(original);
    final target = File('${root.path}/ar.pack.gz');
    await Link(target.path).create(outside.path);
    final staged = File('${root.path}/staged.pack.gz');
    final bytes = <int>[9, 8, 7];
    await staged.writeAsBytes(bytes);

    await expectLater(
      storage.promoteVerifiedArchive(
        stagedFile: staged,
        targetFile: target,
        expectedSize: bytes.length,
        expectedHash: sha256.convert(bytes).toString(),
      ),
      throwsFormatException,
    );
    expect(await outside.readAsBytes(), original);
    expect(await Link(target.path).exists(), isTrue);
    expect(await staged.readAsBytes(), bytes);
  });

  test('symlinked staging parent cannot bypass archive path guard', () async {
    if (Platform.isWindows) return;
    final target = await targetWithOldPack();
    final actual = await root.createTemp('real-stage-');
    final bytes = <int>[9, 8, 7];
    await File('${actual.path}/ar.pack.gz').writeAsBytes(bytes);
    final alias = Link('${root.path}/alias-stage');
    await alias.create(actual.path);
    final staged = File('${alias.path}/ar.pack.gz');

    await expectLater(
      storage.promoteVerifiedArchive(
        stagedFile: staged,
        targetFile: target,
        expectedSize: bytes.length,
        expectedHash: sha256.convert(bytes).toString(),
      ),
      throwsFormatException,
    );
    expect(await target.readAsBytes(), <int>[1, 2, 3, 4]);
    expect(await File('${actual.path}/ar.pack.gz').readAsBytes(), bytes);
  });

  test('short download cannot replace last-known-good archive', () async {
    final target = await targetWithOldPack();
    final staged = File('${root.path}/short.pack.gz');
    await staged.writeAsBytes(<int>[9, 9]);

    await expectLater(
      storage.promoteVerifiedArchive(
        stagedFile: staged,
        targetFile: target,
        expectedSize: 3,
        expectedHash: sha256.convert(<int>[9, 9]).toString(),
      ),
      throwsFormatException,
    );
    expect(await target.readAsBytes(), <int>[1, 2, 3, 4]);
  });

  test('failed promotion does not delete the previous archive', () async {
    final target = await targetWithOldPack();
    final missing = File('${root.path}/missing.pack.gz');

    await expectLater(
      storage.promoteVerifiedArchive(
        stagedFile: missing,
        targetFile: target,
        expectedSize: 3,
        expectedHash: sha256.convert(<int>[9, 9, 9]).toString(),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(await target.readAsBytes(), <int>[1, 2, 3, 4]);
  });

  test('manifest archive sizes are bounded before disk or network access',
      () async {
    LanguagePackMetadata metadata(int size) => LanguagePackMetadata(
          code: 'ar',
          name: 'Arabic',
          nativeName: 'العربية',
          sizeBytes: size,
          packFile: 'ar-1.0.0.pack.gz',
          sha256Hex: sha256.convert(<int>[1, 2, 3]).toString(),
          isAvailable: true,
        );

    expect(metadata(LanguagePackMetadata.maxArchiveBytes).canDownload, isTrue);
    expect(metadata(LanguagePackMetadata.maxArchiveBytes + 1).canDownload,
        isFalse);
    expect(metadata(0).canDownload, isFalse);

    final progress = <double>[];
    await expectLater(
      storage.download(
        metadata(LanguagePackMetadata.maxArchiveBytes + 1),
        onProgress: progress.add,
      ),
      throwsStateError,
    );
    expect(progress, isEmpty);
  });

  test('promotion refuses an oversized manifest without touching old archive',
      () async {
    final target = await targetWithOldPack();
    final staged = File('${root.path}/oversized.pack.gz');
    await staged.writeAsBytes(<int>[9, 9, 9]);
    await expectLater(
      storage.promoteVerifiedArchive(
        stagedFile: staged,
        targetFile: target,
        expectedSize: LanguagePackMetadata.maxArchiveBytes + 1,
        expectedHash: sha256.convert(<int>[9, 9, 9]).toString(),
      ),
      throwsFormatException,
    );
    expect(await target.readAsBytes(), <int>[1, 2, 3, 4]);
    expect(await staged.readAsBytes(), <int>[9, 9, 9]);
  });
  test('symlinked grandparent of staged archive cannot bypass validation',
      () async {
    if (Platform.isWindows) return;
    final target = await targetWithOldPack();
    final real = await root.createTemp('real-stage-');
    final nested = Directory('${real.path}/nested');
    await nested.create();
    final bytes = <int>[9, 8, 7];
    final originalStage = File('${nested.path}/ar.pack.gz');
    await originalStage.writeAsBytes(bytes);
    final alias = Link('${root.path}/alias-stage');
    await alias.create(real.path);
    final staged = File('${alias.path}/nested/ar.pack.gz');

    await expectLater(
      storage.promoteVerifiedArchive(
        stagedFile: staged,
        targetFile: target,
        expectedSize: bytes.length,
        expectedHash: sha256.convert(bytes).toString(),
      ),
      throwsFormatException,
    );
    expect(await target.readAsBytes(), <int>[1, 2, 3, 4]);
    expect(await originalStage.readAsBytes(), bytes);
  });

  test('symlinked grandparent of destination cannot replace external archive',
      () async {
    if (Platform.isWindows) return;
    final outside = await root.createTemp('outside-');
    final nested = Directory('${outside.path}/nested');
    await nested.create();
    final external = File('${nested.path}/ar.pack.gz');
    final oldBytes = <int>[1, 2, 3, 4];
    await external.writeAsBytes(oldBytes);
    final alias = Link('${root.path}/alias-target');
    await alias.create(outside.path);
    final target = File('${alias.path}/nested/ar.pack.gz');
    final staged = File('${root.path}/verified.pack.gz');
    final bytes = <int>[9, 8, 7];
    await staged.writeAsBytes(bytes);

    await expectLater(
      storage.promoteVerifiedArchive(
        stagedFile: staged,
        targetFile: target,
        expectedSize: bytes.length,
        expectedHash: sha256.convert(bytes).toString(),
      ),
      throwsFormatException,
    );
    expect(await external.readAsBytes(), oldBytes);
    expect(await staged.readAsBytes(), bytes);
  });
}
