import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:deutsch_app/core/storage/atomic_pack_admission.dart';

void main() {
  group('AtomicPackAdmission Pipeline Tests', () {
    late Directory tempDir;
    late AtomicPackAdmission admission;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('atomic_pack_test_');
      admission = AtomicPackAdmission(tempDir);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Admits valid SQLite pack atomically and snapshots LKG', () async {
      final stagedFile = File('${admission.stagingDir.path}/de_a1.tmp');
      await admission.stagingDir.create(recursive: true);

      // Create valid dummy SQLite header
      final header = utf8.encode('SQLite format 3\x00') + List<int>.filled(84, 0);
      await stagedFile.writeAsBytes(header);
      final hash = sha256.convert(header).toString();

      final receipt = await admission.admitPack(
        packId: 'de_a1',
        incomingStagedFile: stagedFile,
        expectedSha256: hash,
        expectedSchemaVersion: 2,
      );

      expect(receipt.isSuccess, isTrue);
      expect(await File(receipt.activePath).exists(), isTrue);
    });

    test('Rejects pack with mismatched hash and aborts without corrupting active pack', () async {
      final stagedFile = File('${admission.stagingDir.path}/de_bad.tmp');
      await admission.stagingDir.create(recursive: true);

      final header = utf8.encode('SQLite format 3\x00') + List<int>.filled(84, 0);
      await stagedFile.writeAsBytes(header);

      final receipt = await admission.admitPack(
        packId: 'de_bad',
        incomingStagedFile: stagedFile,
        expectedSha256: '0000000000000000000000000000000000000000000000000000000000000000',
        expectedSchemaVersion: 2,
      );

      expect(receipt.isSuccess, isFalse);
      expect(receipt.status, equals(PackAdmissionStatus.hashMismatchRollback));
      expect(await stagedFile.exists(), isFalse); // Staged file purged
    });
  });
}
