import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/core/storage/pack_admission_service.dart';
import '../../../lib/core/storage/storage_quarantine.dart';
import '../../../lib/core/storage/atomic_database_installer.dart';

void main() {
  late PackAdmissionService service;
  late StorageQuarantine quarantine;
  late DatabaseFactory dbFactory;
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() {
    quarantine = StorageQuarantine();
    dbFactory = databaseFactoryFfi;
    service = PackAdmissionService(
      quarantine: quarantine,
      dbFactory: dbFactory,
    );
    tempDir = Directory.systemTemp.createTempSync('j003_test_dir_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<File> createValidSqliteFile(String filename) async {
    final file = File('${tempDir.path}/$filename');
    final db = await dbFactory.openDatabase(file.path, options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async {
      await db.execute('CREATE TABLE data (id INTEGER PRIMARY KEY, value TEXT)');
      await db.execute('PRAGMA user_version = 1');
    }));
    await db.close();
    return file;
  }

  test('Valid pack is admitted and installed atomically', () async {
    final sourceFile = await createValidSqliteFile('valid.pack');
    final bytes = await sourceFile.readAsBytes();
    final hash = sha256.convert(bytes).toString();
    final targetPath = '${tempDir.path}/target.pack';

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isTrue);
    expect(File(targetPath).existsSync(), isTrue);
  });

  test('Corrupted hash rejects pack and quarantines it', () async {
    final sourceFile = await createValidSqliteFile('corrupted.pack');
    final targetPath = '${tempDir.path}/target2.pack';

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: 'invalid_hash',
      targetPath: targetPath,
    );

    expect(result, isFalse);
    expect(File(targetPath).existsSync(), isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, contains('Hash mismatch'));
  });

  test('Invalid SQLite header rejects pack', () async {
    final file = File('${tempDir.path}/invalid.pack');
    await file.writeAsBytes([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]); // Not SQLite header
    final bytes = await file.readAsBytes();
    final hash = sha256.convert(bytes).toString();
    final targetPath = '${tempDir.path}/target3.pack';

    final result = await service.verifyAndAdmitPack(
      stagedFile: file,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isFalse);
    expect(File(targetPath).existsSync(), isFalse);
  });

  test('Progress path is rejected', () async {
    final sourceFile = await createValidSqliteFile('progress.pack');
    final bytes = await sourceFile.readAsBytes();
    final hash = sha256.convert(bytes).toString();
    final targetPath = '${tempDir.path}/my_progress.pack';

    final result = await service.verifyAndAdmitPack(
      stagedFile: sourceFile,
      expectedHash: hash,
      targetPath: targetPath,
    );

    expect(result, isFalse);
    expect(File(targetPath).existsSync(), isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.last.diagnosticReason, contains('progress'));
  });
}
