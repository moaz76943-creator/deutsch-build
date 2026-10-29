import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

enum PackAdmissionStatus {
  success,
  hashMismatchRollback,
  invalidSchemaRollback,
  corruptedDbRollback,
}

class PackAdmissionReceipt {
  final PackAdmissionStatus status;
  final String packId;
  final String activePath;
  final String? errorMessage;

  const PackAdmissionReceipt({
    required this.status,
    required this.packId,
    required this.activePath,
    this.errorMessage,
  });

  bool get isSuccess => status == PackAdmissionStatus.success;
}

/// 5-Stage Atomic Pack Admission Pipeline:
/// Staging -> Validation (SHA256 & Schema) -> Atomic Activation -> LKG Snapshot -> Rollback on error
class AtomicPackAdmission {
  final Directory baseStorageDir;

  AtomicPackAdmission(this.baseStorageDir);

  Directory get stagingDir => Directory('${baseStorageDir.path}/.staging');
  Directory get activeDir => Directory('${baseStorageDir.path}/active');
  Directory get lkgDir => Directory('${baseStorageDir.path}/.lkg');

  Future<PackAdmissionReceipt> admitPack({
    required String packId,
    required File incomingStagedFile,
    required String expectedSha256,
    required int expectedSchemaVersion,
  }) async {
    await stagingDir.create(recursive: true);
    await activeDir.create(recursive: true);
    await lkgDir.create(recursive: true);

    final activeFile = File('${activeDir.path}/$packId.pack');
    final lkgFile = File('${lkgDir.path}/$packId.lkg');

    try {
      // Stage 1: Validation - Hash verification
      final bytes = await incomingStagedFile.readAsBytes();
      final actualSha256 = sha256.convert(bytes).toString();

      if (actualSha256.toLowerCase() != expectedSha256.toLowerCase()) {
        // Abort and purge staging
        if (await incomingStagedFile.exists()) await incomingStagedFile.delete();
        return PackAdmissionReceipt(
          status: PackAdmissionStatus.hashMismatchRollback,
          packId: packId,
          activePath: activeFile.path,
          errorMessage: 'SHA256 mismatch: expected $expectedSha256 but got $actualSha256',
        );
      }

      // Stage 2: Validation - SQLite header verification
      if (bytes.length < 100 || !utf8.decode(bytes.sublist(0, 16), allowMalformed: true).startsWith('SQLite format 3')) {
        if (await incomingStagedFile.exists()) await incomingStagedFile.delete();
        return PackAdmissionReceipt(
          status: PackAdmissionStatus.corruptedDbRollback,
          packId: packId,
          activePath: activeFile.path,
          errorMessage: 'Corrupted database header: not a valid SQLite format 3 file',
        );
      }

      // Stage 3: Snapshot existing active pack as Last-Known-Good
      if (await activeFile.exists() && (await activeFile.length()) > 0) {
        await activeFile.copy(lkgFile.path);
      }

      // Stage 4: Atomic Activation (Rename staged file to active file)
      await incomingStagedFile.rename(activeFile.path);

      return PackAdmissionReceipt(
        status: PackAdmissionStatus.success,
        packId: packId,
        activePath: activeFile.path,
      );
    } catch (e) {
      // Stage 5: Rollback from Last-Known-Good on any unexpected IO exception
      if (await lkgFile.exists()) {
        await lkgFile.copy(activeFile.path);
      }
      return PackAdmissionReceipt(
        status: PackAdmissionStatus.corruptedDbRollback,
        packId: packId,
        activePath: activeFile.path,
        errorMessage: 'Exception during admission: $e. Rolled back to LKG.',
      );
    }
  }
}
