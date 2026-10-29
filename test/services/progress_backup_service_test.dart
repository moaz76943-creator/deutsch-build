import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:deutsch_bilarabi/services/progress_backup_service.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Deterministic test boundary, not a substitute for native AES-GCM tests.
class _FakeCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String id, Uint8List data) async =>
      Uint8List.fromList(<int>[1, ...List<int>.filled(28, 0),
        ...data.map((value) => value ^ 0x55)]);

  @override
  Future<Uint8List> decrypt(String id, Uint8List data) async =>
      Uint8List.fromList(data.skip(29).map((value) => value ^ 0x55));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory temporary;
  late Database vaultDb;
  late UserVaultSecurityService vault;
  late ProgressBackupService backup;

  Future<Database> emptyVaultDatabase() async {
    final db = await openDatabase(inMemoryDatabasePath, singleInstance: false);
    await db.execute('CREATE TABLE vault_entries ('
        'record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)');
    return db;
  }

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('progress-vault-backup-');
    vaultDb = await emptyVaultDatabase();
    vault = UserVaultSecurityService(
      cipher: _FakeCipher(), openVaultDatabase: () async => vaultDb,
      legacyDatabasePath: () async => '${temporary.path}/user_progress_v2.db',
    );
    backup = ProgressBackupService(
      vaultService: vault, backupDirectoryProvider: () async => temporary);
  });

  tearDown(() async {
    await vaultDb.close();
    await temporary.delete(recursive: true);
  });

  test('live vault export contains next due, actual review time and bookmarks', () async {
    final timestamp = DateTime.utc(2026, 10, 11, 18);
    final scheduled = await vault.gradeOperationalSrs(
      lexemeId: 'Haus', languageCode: 'de', grade: 3,
      reviewedAt: timestamp);
    await vault.putOperationalBookmark(
      bookmarkId: 'one', languageCode: 'de', data: {'word': 'Buch'});

    final saved = await backup.exportBackup();
    final payload = jsonDecode(utf8.decode(gzip.decode(
        await File(saved).readAsBytes()))) as Map<String, dynamic>;
    expect(payload['version'], 2);
    expect(payload['source_database'], 'user_vault_v1.db');
    final records = payload['records'] as List;
    expect(records, hasLength(1));
    expect(records.single['lexeme_id'], 'Haus');
    expect(records.single['next_due_at'], scheduled.nextReviewEpoch);
    expect(records.single['last_reviewed_at'],
        timestamp.millisecondsSinceEpoch ~/ 1000);
    final bookmarks = payload['bookmarks'] as List;
    expect(bookmarks.single['data']['word'], 'Buch');
    expect((await vaultDb.query('vault_entries')).toString(),
        isNot(contains('Haus')));
  });

  test('AES archive is opaque and imports SRS/bookmarks atomically', () async {
    await vault.gradeOperationalSrs(
      lexemeId: 'Haus', languageCode: 'de', grade: 3);
    await vault.putOperationalBookmark(
      bookmarkId: 'b', languageCode: 'tr', data: {'word': 'ev'});
    final archive = await backup.exportBackup(encryptedArchive: true);
    expect(archive, endsWith('.vault.json'));
    expect(await File(archive).readAsString(), isNot(contains('Haus')));

    final restoredDb = await emptyVaultDatabase();
    try {
      final restoredVault = UserVaultSecurityService(
        cipher: _FakeCipher(), openVaultDatabase: () async => restoredDb,
        legacyDatabasePath: () async => '${temporary.path}/fresh-missing.db');
      final receiver = ProgressBackupService(
        vaultService: restoredVault,
        backupDirectoryProvider: () async => temporary);
      final result = await receiver.importBackup(archive);
      expect(result.inserted, 1);
      expect(result.bookmarksInserted, 1);
      expect((await restoredVault.readOperationalSrs(
          lexemeId: 'Haus', languageCode: 'de'))?['repetition_count'], 1);
      expect((await restoredVault.readOperationalBookmark(
          bookmarkId: 'b', languageCode: 'tr'))?['word'], 'ev');
      final second = await receiver.importBackup(archive);
      expect(second.unchanged, 1);
    } finally {
      await restoredDb.close();
    }
  });

  test('pending migration exports legacy DB without vault catalog', () async {
    final oldPath = '${temporary.path}/user_progress_v2.db';
    final legacy = await openDatabase(oldPath, singleInstance: false);
    try {
      await legacy.execute('''
        CREATE TABLE srs_progress (
          lexeme_id TEXT NOT NULL, target_language_code TEXT NOT NULL,
          repetition_count INTEGER NOT NULL, interval_days INTEGER NOT NULL,
          ease_factor REAL NOT NULL, next_due_at INTEGER, status TEXT NOT NULL,
          PRIMARY KEY(lexeme_id, target_language_code))
      ''');
      await legacy.insert('srs_progress', {
        'lexeme_id': 'legacy', 'target_language_code': 'fr',
        'repetition_count': 2, 'interval_days': 6,
        'ease_factor': 2.5, 'next_due_at': 123456789,
        'status': 'review',
      });
      await legacy.execute(
          'CREATE TABLE bookmarks (id TEXT PRIMARY KEY, word TEXT NOT NULL)');
      await legacy.insert('bookmarks', {'id': 'legacy-b', 'word': 'livre'});
      final service = ProgressBackupService(
        vaultService: vault, databaseProvider: () async => legacy,
        backupDirectoryProvider: () async => temporary);
      final path = await service.exportBackup();
      final payload = jsonDecode(utf8.decode(gzip.decode(
          await File(path).readAsBytes()))) as Map<String, dynamic>;
      expect(payload['source_database'], 'user_progress_v2.db');
      expect((payload['records'] as List).single['lexeme_id'], 'legacy');
      expect((payload['records'] as List).single['last_reviewed_at'], isNull);
      expect((payload['bookmarks'] as List).single['data']['word'], 'livre');
      expect(await vault.isOperationalActive, isFalse);
      expect(await vaultDb.query('vault_entries'), isEmpty);
    } finally {
      await legacy.close();
    }
  });
}
