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
}
