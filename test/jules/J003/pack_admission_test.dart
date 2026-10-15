import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:deutsch_bilarabi/core/storage/pack_admission_service.dart';
import 'package:deutsch_bilarabi/core/storage/atomic_database_installer.dart';
import 'package:deutsch_bilarabi/core/storage/storage_quarantine.dart';
import 'test_setup.dart';

void main() {
  setUpAll(() {
    setupSqfliteFfi();
  });

  late Directory tempDir;
  late StorageQuarantine quarantine;
  late PackAdmissionService admissionService;
  late String quarantineDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pack_admission_test_');
    quarantineDir = p.join(tempDir.path, 'quarantine');
    quarantine = StorageQuarantine();
    admissionService = PackAdmissionService(quarantine: quarantine);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<File> createValidDatabase(String path) async {
    final dbPath = p.join(tempDir.path, path);
    final db = await databaseFactory.openDatabase(dbPath);

    // Valid Schema Setup
    await db.execute('PRAGMA user_version = 1;');
    await db.execute('''
      CREATE TABLE language_profiles (
        language_code TEXT PRIMARY KEY,
        name_native TEXT NOT NULL,
        name_ar TEXT NOT NULL,
        direction TEXT NOT NULL
      )
    ''');
    await db.insert('language_profiles', {
      'language_code': 'de',
      'name_native': 'Deutsch',
      'name_ar': 'ألمانية',
      'direction': 'ltr',
    });

    await db.execute('''
      CREATE TABLE lexemes (
        lexeme_id TEXT PRIMARY KEY,
        concept_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        lemma TEXT NOT NULL,
        display_text TEXT NOT NULL
      )
    ''');
    await db.insert('lexemes', {
      'lexeme_id': 'lex_1',
      'concept_id': 'conc_1',
      'language_code': 'de',
      'lemma': 'hund',
      'display_text': 'Hund',
    });

    await db.close();
    return File(dbPath);
  }

  Future<String> calculateHash(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  test('Admit valid pack successfully', () async {
    final sourceDb = await createValidDatabase('valid_pack.db');
    final hash = await calculateHash(sourceDb);
    final targetPath = p.join(tempDir.path, 'target_pack.db');

    final result = await admissionService.installPack(
      sourcePath: sourceDb.path,
      targetPath: targetPath,
      expectedHash: hash,
      quarantineDir: quarantineDir,
    );

    expect(result.status, DatabaseInstallStatus.installed);
    expect(await File(targetPath).exists(), isTrue);
    expect((await quarantine.getIsolatedFiles(quarantineDir)).isEmpty, isTrue);
  });

  test('Reject pack with invalid hash and quarantine it', () async {
    final sourceDb = await createValidDatabase('invalid_hash.db');
    final targetPath = p.join(tempDir.path, 'target_invalid_hash.db');

    final result = await admissionService.installPack(
      sourcePath: sourceDb.path,
      targetPath: targetPath,
      expectedHash: 'bad_hash',
      quarantineDir: quarantineDir,
    );

    expect(result.status, DatabaseInstallStatus.rejected);
    expect(await File(targetPath).exists(), isFalse);
    final isolated = await quarantine.getIsolatedFiles(quarantineDir);
    expect(isolated.length, 1);
  });

  test('Reject pack with no language profiles (invalid schema)', () async {
    final dbPath = p.join(tempDir.path, 'no_lang.db');
    final db = await databaseFactory.openDatabase(dbPath);
    await db.execute('PRAGMA user_version = 1;');
    await db.execute('CREATE TABLE language_profiles (language_code TEXT PRIMARY KEY)');
    await db.execute('CREATE TABLE lexemes (lexeme_id TEXT PRIMARY KEY)');
    await db.insert('lexemes', {'lexeme_id': 'lex_1'});
    await db.close();

    final sourceFile = File(dbPath);
    final hash = await calculateHash(sourceFile);
    final targetPath = p.join(tempDir.path, 'target_no_lang.db');

    final result = await admissionService.installPack(
      sourcePath: sourceFile.path,
      targetPath: targetPath,
      expectedHash: hash,
      quarantineDir: quarantineDir,
    );

    expect(result.status, DatabaseInstallStatus.rejected);
    expect(await File(targetPath).exists(), isFalse);
    final isolated = await quarantine.getIsolatedFiles(quarantineDir);
    expect(isolated.length, 1);
  });

  test('Reject pack with no lexemes', () async {
    final dbPath = p.join(tempDir.path, 'no_lex.db');
    final db = await databaseFactory.openDatabase(dbPath);
    await db.execute('PRAGMA user_version = 1;');
    await db.execute('CREATE TABLE language_profiles (language_code TEXT PRIMARY KEY)');
    await db.insert('language_profiles', {'language_code': 'de'});
    await db.execute('CREATE TABLE lexemes (lexeme_id TEXT PRIMARY KEY)');
    await db.close();

    final sourceFile = File(dbPath);
    final hash = await calculateHash(sourceFile);
    final targetPath = p.join(tempDir.path, 'target_no_lex.db');

    final result = await admissionService.installPack(
      sourcePath: sourceFile.path,
      targetPath: targetPath,
      expectedHash: hash,
      quarantineDir: quarantineDir,
    );

    expect(result.status, DatabaseInstallStatus.rejected);
    expect(await File(targetPath).exists(), isFalse);
    final isolated = await quarantine.getIsolatedFiles(quarantineDir);
    expect(isolated.length, 1);
  });

  test('Reject corrupted byte file', () async {
    final dbPath = p.join(tempDir.path, 'corrupted.db');
    final file = File(dbPath);
    await file.writeAsBytes([0x00, 0x01, 0x02, 0x03]); // Not a valid SQLite DB

    final hash = await calculateHash(file);
    final targetPath = p.join(tempDir.path, 'target_corrupted.db');

    final result = await admissionService.installPack(
      sourcePath: file.path,
      targetPath: targetPath,
      expectedHash: hash,
      quarantineDir: quarantineDir,
    );

    expect(result.status, DatabaseInstallStatus.rejected);
    expect(await File(targetPath).exists(), isFalse);
    final isolated = await quarantine.getIsolatedFiles(quarantineDir);
    expect(isolated.length, 1);
  });

  test('Atomic replacement replaces existing valid pack', () async {
    // 1. Install first valid pack
    final source1 = await createValidDatabase('valid_pack1.db');
    final hash1 = await calculateHash(source1);
    final targetPath = p.join(tempDir.path, 'production.db');

    final result1 = await admissionService.installPack(
      sourcePath: source1.path,
      targetPath: targetPath,
      expectedHash: hash1,
      quarantineDir: quarantineDir,
    );
    expect(result1.status, DatabaseInstallStatus.installed);

    // 2. Install second valid pack over it
    final source2 = await createValidDatabase('valid_pack2.db');
    // Add extra data to differentiate
    final db2 = await databaseFactory.openDatabase(source2.path);
    await db2.insert('lexemes', {
      'lexeme_id': 'lex_2',
      'concept_id': 'conc_2',
      'language_code': 'de',
      'lemma': 'katze',
      'display_text': 'Katze',
    });
    await db2.close();

    final hash2 = await calculateHash(source2);
    final result2 = await admissionService.installPack(
      sourcePath: source2.path,
      targetPath: targetPath,
      expectedHash: hash2,
      quarantineDir: quarantineDir,
    );

    expect(result2.status, DatabaseInstallStatus.installed);

    // Verify it was actually replaced
    final verifyDb = await databaseFactory.openDatabase(targetPath, options: OpenDatabaseOptions(readOnly: true));
    final count = (await verifyDb.rawQuery('SELECT COUNT(*) FROM lexemes')).first.values.first as int;
    await verifyDb.close();
    expect(count, 2);
  });

  test('Failed replacement preserves previous valid pack', () async {
    // 1. Install a valid pack
    final validSource = await createValidDatabase('valid_pack1.db');
    final hash1 = await calculateHash(validSource);
    final targetPath = p.join(tempDir.path, 'production.db');

    final result1 = await admissionService.installPack(
      sourcePath: validSource.path,
      targetPath: targetPath,
      expectedHash: hash1,
      quarantineDir: quarantineDir,
    );
    expect(result1.status, DatabaseInstallStatus.installed);

    final targetFile = File(targetPath);
    final oldStat = await targetFile.stat();

    // 2. Attempt to install an invalid pack over it
    final invalidSource = await createValidDatabase('invalid2.db'); // Valid DB but wrong hash
    final result2 = await admissionService.installPack(
      sourcePath: invalidSource.path,
      targetPath: targetPath,
      expectedHash: 'wrong_hash',
      quarantineDir: quarantineDir,
    );

    expect(result2.status, DatabaseInstallStatus.rejected);

    final newStat = await targetFile.stat();
    expect(oldStat.modified, newStat.modified); // Make sure the original file wasn't touched

    final tmpFile = File('${targetPath}.tmp');
    expect(await tmpFile.exists(), isFalse);
  });

  test('Bounded quarantine retention across sessions', () async {
     for(int i=0; i < 7; i++) {
        final f = File(p.join(tempDir.path, 'bad_file_${i}.db'));
        await f.writeAsString('bad data ${i}');

        // Simulating restart by using a new StorageQuarantine instance each time
        final q = StorageQuarantine();
        await q.isolateCorruptFile(f, 'reason', quarantineDir);
        await Future.delayed(const Duration(milliseconds: 10));
     }

     final isolated = await quarantine.getIsolatedFiles(quarantineDir);
     expect(isolated.length, 5); // Max is 5
  });

  test('Interrupted rename recovers gracefully', () async {
    // Simulate leftover tmp file from previous interrupted run
    final targetPath = p.join(tempDir.path, 'target_pack.db');
    final tmpFile = File('${targetPath}.tmp');
    await tmpFile.writeAsString('leftover junk data');

    final sourceDb = await createValidDatabase('valid_pack.db');
    final hash = await calculateHash(sourceDb);

    final result = await admissionService.installPack(
      sourcePath: sourceDb.path,
      targetPath: targetPath,
      expectedHash: hash,
      quarantineDir: quarantineDir,
    );

    expect(result.status, DatabaseInstallStatus.installed);
    expect(await File(targetPath).exists(), isTrue);

    // The previous temp file should have been overwritten or cleaned up
    final currentDbData = await File(targetPath).readAsBytes();
    final sourceDbData = await sourceDb.readAsBytes();
    expect(currentDbData, sourceDbData);
  });
}
