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

  /// Synthetic v2 fixture, not distributable educational content.
  Future<File> createValidDatabase(String filename) async {
    final file = File('${tempDir.path}/$filename');
    final db = await databaseFactoryFfi.openDatabase(file.path);
    try {
      await db.execute('PRAGMA user_version = 2');
      await db.execute('CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
      await db.execute('CREATE TABLE schema_migrations (version INTEGER)');
      await db.execute('CREATE TABLE concepts (concept_id TEXT PRIMARY KEY)');
      await db.execute('''
        CREATE TABLE lexicon (
          id TEXT PRIMARY KEY, surface TEXT, sort_key TEXT,
          language_code TEXT, cefr_level TEXT, part_of_speech TEXT,
          fields_json TEXT
        )
      ''');
      await db.execute('CREATE TABLE senses (sense_id TEXT, lexeme_id TEXT, concept_id TEXT, payload_json TEXT)');
      await db.execute('CREATE TABLE translations (id TEXT)');
      await db.execute('CREATE TABLE examples (example_id TEXT, lexeme_id TEXT, language_code TEXT, text TEXT)');
      await db.execute('CREATE TABLE lexical_relations (id TEXT)');
      await db.execute('CREATE TABLE grammar (id TEXT)');
      await db.execute('CREATE TABLE data (id INTEGER PRIMARY KEY, value BLOB)');
      await db.execute('CREATE VIEW lexemes AS SELECT id, surface FROM lexicon');
      await db.execute('CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface)');
      for (final metadata in <List<String>>[
        ['mapping_version', '2.0.0'],
        ['contract_version', '1.0.0'],
        ['language_code', 'fr'],
      ]) {
        await db.insert('metadata', <String, Object?>{
          'key': metadata[0], 'value': metadata[1],
        });
      }
      await db.insert('lexicon', <String, Object?>{
        'id': 'lex.fr.test',
        'surface': 'bonjour',
        'sort_key': 'bonjour',
        'language_code': 'fr',
        'cefr_level': 'A1',
        'part_of_speech': 'interjection',
        'fields_json': '{}',
      });
    } finally {
      await db.close();
    }
    return file;
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
      languageCode: 'fr',
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
      languageCode: 'fr',
      allowReplacement: true,
    );
    expect(result2, isTrue);
  });

  test('streaming SHA-256 admits a large SQLite file without a full Dart byte buffer', () async {
    final stagedDb = await createValidDatabase('large_staged.db');
    final db = await databaseFactoryFfi.openDatabase(stagedDb.path);
    try {
      // SQLite allocates the BLOB directly; the test does not load it into Dart.
      await db.rawInsert(
        'INSERT INTO data(value) VALUES (zeroblob(?))',
        <Object?>[4 * 1024 * 1024],
      );
    } finally {
      await db.close();
    }

    final expectedHash =
        (await sha256.bind(stagedDb.openRead()).first).toString();
    final targetPath = '${tempDir.path}/large_target.db';

    final admitted = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedDb,
      expectedHash: expectedHash,
      targetPath: targetPath,
      languageCode: 'fr',
    );

    expect(admitted, isTrue);
    final admittedFile = File(targetPath);
    expect(await admittedFile.exists(), isTrue);
    expect(await admittedFile.length(), greaterThan(4 * 1024 * 1024));
    expect(
      (await sha256.bind(admittedFile.openRead()).first).toString(),
      expectedHash,
    );
  });

  test('uppercase digest is accepted when checksum bytes match', () async {
    final stagedDb = await createValidDatabase('uppercase_staged.db');
    final checksum = await calculateHash(stagedDb);
    final targetPath = '${tempDir.path}/uppercase_target.db';

    final admitted = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedDb,
      expectedHash: checksum.toUpperCase(),
      targetPath: targetPath,
      languageCode: 'fr',
    );
    expect(admitted, isTrue);
    expect(await File(targetPath).exists(), isTrue);
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
      languageCode: 'fr',
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
      languageCode: 'fr',
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
      languageCode: 'fr',
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
      languageCode: 'fr',
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, 'Invalid schema version');
  });

  test('Orphaned foreign keys reject admission and preserve installed pack',
      () async {
    final target = await createValidDatabase('installed_verified.db');
    final originalHash = await calculateHash(target);

    final orphaned = File('${tempDir.path}/orphaned_candidate.db');
    final db = await databaseFactoryFfi.openDatabase(orphaned.path);
    try {
      await db.execute('PRAGMA foreign_keys = OFF');
      await db.execute('PRAGMA user_version = 1');
      await db.execute('CREATE TABLE parent (id INTEGER PRIMARY KEY)');
      await db.execute(
        'CREATE TABLE child (id INTEGER PRIMARY KEY, '
        'parent_id INTEGER NOT NULL REFERENCES parent(id))',
      );
      await db.insert('child', {'id': 1, 'parent_id': 999});
      expect(
        (await db.rawQuery('PRAGMA integrity_check')).single.values.single,
        'ok',
      );
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isNotEmpty);
    } finally {
      await db.close();
    }

    final result = await admissionService.verifyAndAdmitPack(
      stagedFile: orphaned,
      expectedHash: await calculateHash(orphaned),
      targetPath: target.path,
      languageCode: 'fr',
      allowReplacement: true,
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.any(
      (item) => item.diagnosticReason == 'SQLite foreign key check failed',
    ), isTrue);
    expect(await calculateHash(target), originalHash);
    expect(await File('${target.path}.tmp').exists(), isFalse);
  });

  test('Enforced separation of learner data', () async {
    final stagedDb = await createValidDatabase('staged.db');
    final hash = await calculateHash(stagedDb);
    final targetPath = '${tempDir.path}/user_progress.db';

    bool result = await admissionService.verifyAndAdmitPack(
      stagedFile: stagedDb,
      expectedHash: hash,
      targetPath: targetPath,
      languageCode: 'fr',
    );

    expect(result, isFalse);
    expect(quarantine.isolatedItems.isNotEmpty, isTrue);
    expect(quarantine.isolatedItems.first.diagnosticReason, 'Attempted to overwrite progress database');
  });

  test('v1 SQLite cannot overwrite a previously admitted v2 pack', () async {
    final target = await createValidDatabase('safe_v2.db');
    final original = await calculateHash(target);
    final candidate = File('${tempDir.path}/legacy_v1.db');
    final db = await databaseFactoryFfi.openDatabase(candidate.path);
    await db.execute('PRAGMA user_version = 1');
    await db.execute('CREATE TABLE data (value TEXT)');
    await db.close();
    final accepted = await admissionService.verifyAndAdmitPack(
      stagedFile: candidate,
      expectedHash: await calculateHash(candidate),
      targetPath: target.path,
      languageCode: 'fr',
      allowReplacement: true,
    );
    expect(accepted, isFalse);
    expect(await calculateHash(target), original);
    expect(quarantine.isolatedItems.any(
      (item) => item.diagnosticReason == 'Invalid schema version',
    ), isTrue);
  });

  test('Wrong v2 language identity cannot overwrite valid content', () async {
    final target = await createValidDatabase('safe_identity.db');
    final original = await calculateHash(target);
    final candidate = await createValidDatabase('wrong_identity.db');
    final accepted = await admissionService.verifyAndAdmitPack(
      stagedFile: candidate,
      expectedHash: await calculateHash(candidate),
      targetPath: target.path,
      languageCode: 'de',
      allowReplacement: true,
    );
    expect(accepted, isFalse);
    expect(await calculateHash(target), original);
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
