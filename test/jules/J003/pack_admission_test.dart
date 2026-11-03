import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/core/storage/atomic_database_installer.dart';
import 'package:deutsch_bilarabi/core/storage/pack_admission_service.dart';
import 'package:deutsch_bilarabi/core/storage/storage_quarantine.dart';

void main() {
  late StorageQuarantine quarantine;
  late PackAdmissionService admissionService;
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('j003_test_');
    quarantine = StorageQuarantine();
    // Clear any previous state if needed, though a new instance is created.
    admissionService = PackAdmissionService(
      quarantine: quarantine,
      dbFactory: databaseFactoryFfi,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<File> createValidDatabase(String filename) async {
    final path = '${tempDir.path}/$filename';
    final db = await databaseFactoryFfi.openDatabase(path);
    await db.execute('PRAGMA user_version = 2');

    await db.execute('CREATE TABLE schema_migrations (id INTEGER PRIMARY KEY)');
    await db.execute('CREATE TABLE concepts (id INTEGER PRIMARY KEY)');
    await db.execute('CREATE TABLE translations (id INTEGER PRIMARY KEY)');
    await db.execute('CREATE TABLE lexical_relations (id INTEGER PRIMARY KEY)');
    await db.execute('CREATE TABLE grammar (id INTEGER PRIMARY KEY)');

    await db.execute('CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT)');
    await db.execute('''CREATE TABLE lexicon (
      id TEXT PRIMARY KEY,
      surface TEXT,
      sort_key TEXT,
      language_code TEXT,
      cefr_level TEXT,
      part_of_speech TEXT,
      fields_json TEXT
    )''');
    await db.execute('''CREATE TABLE senses (
      sense_id TEXT PRIMARY KEY,
      lexeme_id TEXT,
      concept_id TEXT,
      payload_json TEXT
    )''');
    await db.execute('''CREATE TABLE examples (
      example_id TEXT PRIMARY KEY,
      lexeme_id TEXT,
      language_code TEXT,
      text TEXT
    )''');

    await db.execute('CREATE VIEW lexemes AS SELECT 1 AS id');
    await db.execute('CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface)');

    await db.insert('metadata', {'key': 'mapping_version', 'value': '2.0.0'});
    await db.insert('metadata', {'key': 'contract_version', 'value': '1.0.0'});
    await db.insert('metadata', {'key': 'language_code', 'value': 'de'});

    await db.insert('lexicon', {
        'id': '1', 'surface': 'test', 'sort_key': 'test', 'language_code': 'de',
        'cefr_level': 'A1', 'part_of_speech': 'noun', 'fields_json': '{}'
    });

    await db.close();
    return File(path);
  }

  Future<File> createInvalidSchemaDatabase(String filename) async {
    final path = '${tempDir.path}/$filename';
    final db = await databaseFactoryFfi.openDatabase(path);
    await db.execute('CREATE TABLE dummy (id INTEGER)'); // to make file not empty
    // user_version is 0 by default, no data tables (we consider 'dummy' as a table, wait no,
    // my check says "excluding sqlite_". So 'dummy' table exists, but user_version is 0.
    // This will fail the user_version check as expected.
    await db.close();
    return File(path);
  }

  Future<String> calculateHash(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  test('Valid admission and replacement', () async {
    final stagedDb = await createValidDatabase('staged.db');
    final hash = await calculateHash(stagedDb);
    final targetPath = '${tempDir.path}/target.db';

    // Install
    bool result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedDb,
      expectedHash: hash,
      targetPath: targetPath,
      languageCode: 'de',
    );
    expect(result, isTrue);
    expect(await File(targetPath).exists(), isTrue);

    // Replace
    final stagedDb2 = await createValidDatabase('staged2.db');
    final hash2 = await calculateHash(stagedDb2);

    bool result2 = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedDb2,
      expectedHash: hash2,
      targetPath: targetPath,
      languageCode: 'de',
      allowReplacement: true,
    );
    expect(result2, isTrue);
  });

  test('Corrupted bytes / SQLite integrity failure', () async {
    final corruptFile = File('${tempDir.path}/corrupt.db');
    await corruptFile.writeAsBytes(List.filled(100, 0)); // Not a valid SQLite DB
    final hash = await calculateHash(corruptFile);
    final targetPath = '${tempDir.path}/target.db';

    bool result = await admissionService.verifyAndAdmitPack(
      stagedFile: corruptFile,
      expectedHash: hash,
      targetPath: targetPath,
      languageCode: 'de',
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, contains('Failed to open or query SQLite database'));
  });

  test('Wrong hash', () async {
    final stagedDb = await createValidDatabase('staged.db');
    const wrongHash = '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
    final targetPath = '${tempDir.path}/target.db';

    bool result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedDb,
      expectedHash: wrongHash,
      targetPath: targetPath,
      languageCode: 'de',
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, 'SHA-256 hash mismatch');
  });

  test('Interrupted renames (startup deletes leftover .tmp)', () async {
    final stagedDb = await createValidDatabase('staged.db');
    final hash = await calculateHash(stagedDb);
    final targetPath = '${tempDir.path}/target.db';

    // Simulate a leftover .tmp file
    final tempFile = File('$targetPath.tmp');
    await tempFile.writeAsString('garbage');
    expect(await tempFile.exists(), isTrue);

    bool result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedDb,
      expectedHash: hash,
      targetPath: targetPath,
      languageCode: 'de',
    );

    expect(result, isTrue);
    expect(await tempFile.exists(), isFalse); // Temp file should be cleaned up
    expect(await File(targetPath).exists(), isTrue);
  });

  test('Invalid schema (version 0 or missing tables)', () async {
    final stagedDb = await createInvalidSchemaDatabase('staged.db');
    final hash = await calculateHash(stagedDb);
    final targetPath = '${tempDir.path}/target.db';

    bool result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedDb,
      expectedHash: hash,
      targetPath: targetPath,
      languageCode: 'de',
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, 'Invalid schema version');
  });

  test('Enforced separation of learner data', () async {
    final stagedDb = await createValidDatabase('staged.db');
    final hash = await calculateHash(stagedDb);
    final targetPath = '${tempDir.path}/user_progress.db';

    bool result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedDb,
      expectedHash: hash,
      targetPath: targetPath,
      languageCode: 'de',
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, 'Attempted to overwrite progress database');
  });

  test('Preserve the last verified pack when replacement fails (simulated)', () async {
    // AtomicDatabaseInstaller handles this because File.rename is atomic
    // If we pass an invalid source, it fails before touching target.
    final targetFile = await createValidDatabase('target.db');
    final originalHash = await calculateHash(targetFile);

    final installResult = await AtomicDatabaseInstaller.installDatabaseAtomically(
      sourcePath: '${tempDir.path}/non_existent.db',
      targetPath: targetFile.path,
      allowReplacement: true,
    );

    expect(installResult.status, DatabaseInstallStatus.failed);
    expect(await targetFile.exists(), isTrue);
    expect(await calculateHash(targetFile), originalHash); // Unchanged
  });
}
