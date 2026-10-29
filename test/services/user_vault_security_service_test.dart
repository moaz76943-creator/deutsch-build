import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Cryptographic contract tests use a deterministic fake; actual Keystore
/// attestation/AES-GCM requires an Android instrumentation test.
class FakeCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String id,Uint8List data) async =>
      Uint8List.fromList(<int>[1,...List<int>.filled(28,0),
        ...data.map((value)=>value^0x55)]);
  @override
  Future<Uint8List> decrypt(String id,Uint8List data) async =>
      Uint8List.fromList(data.skip(29).map((value)=>value^0x55));
}
class SoftwareEnvelopeCipher extends FakeCipher {
  @override
  Future<Uint8List> encrypt(String id, Uint8List data) async {
    final result = await super.encrypt(id, data);
    result[0] = 2;
    return result;
  }
}
class CorruptingCipher extends FakeCipher {
  @override
  Future<Uint8List> decrypt(String id, Uint8List data) async {
    final plain = await super.decrypt(id, data);
    return Uint8List.fromList([...plain, 0]);
  }
}
class BrokenCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String id,Uint8List data) async =>
      throw StateError('hardware unavailable');
  @override
  Future<Uint8List> decrypt(String id,Uint8List data) async =>
      throw StateError('hardware unavailable');
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory=databaseFactoryFfi;
  late Database db;
  setUp(() async {
    db=await openDatabase(inMemoryDatabasePath);
    await db.execute('CREATE TABLE vault_entries ('
      'record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)');
  });
  tearDown(() async =>db.close());

  test('encrypted roundtrip never persists plaintext or raw record id',() async {
    final vault=UserVaultSecurityService(
      cipher:FakeCipher(),openVaultDatabase:() async=>db);
    final content=Uint8List.fromList([65,66,67,68]);
    await vault.putRecord('srs:word-42',content);
    final rows=await db.query('vault_entries');
    expect(rows,hasLength(1));
    expect(rows.single['record_hash'],isNot('srs:word-42'));
    final blob=rows.single['ciphertext'] as Uint8List;
    expect(blob.contains(65),isFalse);
    expect(await vault.readRecord('srs:word-42'),orderedEquals(content));
    await vault.deleteRecord('srs:word-42');
    expect(await vault.readRecord('srs:word-42'),isNull);
  });
  test('crypto boundary failure prevents SQLite writes',() async {
    final vault=UserVaultSecurityService(
      cipher:BrokenCipher(),openVaultDatabase:() async=>db);
    expect(()=>vault.putRecord('notes:1',Uint8List.fromList([42])),
      throwsStateError);
    expect(await db.query('vault_entries'),isEmpty);
  });
  test('reject invalid identifiers and oversized records',() async {
    final vault=UserVaultSecurityService(
      cipher:FakeCipher(),openVaultDatabase:() async=>db);
    expect(()=>vault.putRecord('bad name',Uint8List(1)),
      throwsArgumentError);
    expect(()=>vault.putRecord('srs:1',
      Uint8List(UserVaultSecurityService.maximumRecordBytes+1)),
      throwsArgumentError);
  });

  test('versioned software AES envelope is accepted without plaintext SQLite', () async {
    final vault = UserVaultSecurityService(
      cipher: SoftwareEnvelopeCipher(), openVaultDatabase: () async => db);
    await vault.putRecord('bookmark:1', Uint8List.fromList([72, 105]));
    final encrypted = (await db.query('vault_entries')).single['ciphertext']
        as Uint8List;
    expect(encrypted.first, 2);
    expect(await vault.readRecord('bookmark:1'), [72, 105]);
  });

  test('pending legacy database keeps the original operational route', () async {
    final temporary = await Directory.systemTemp.createTemp('vault-pending-');
    final oldPath = '${temporary.path}/user_progress_v2.db';
    try {
      final legacy = await openDatabase(oldPath, singleInstance: false);
      await legacy.execute('CREATE TABLE srs_progress (lexeme_id TEXT PRIMARY KEY)');
      await legacy.insert('srs_progress', {'lexeme_id': 'keep-learning'});
      await legacy.close();
      final service = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
        legacyDatabasePath: () async => oldPath,
      );
      expect(await service.isOperationalActive, isFalse);
      expect(await File(oldPath).exists(), isTrue);
      expect(await db.query('vault_entries'), isEmpty);
    } finally {
      await temporary.delete(recursive: true);
    }
  });

  test('fresh vault authority remains active if a legacy file appears later', () async {
    final temporary = await Directory.systemTemp.createTemp('vault-fresh-');
    final oldPath = '${temporary.path}/user_progress_v2.db';
    try {
      final service = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
        legacyDatabasePath: () async => oldPath,
      );
      expect(await service.isOperationalActive, isTrue);
      final legacy = await openDatabase(oldPath, singleInstance: false);
      await legacy.close();
      expect(await service.isOperationalActive, isTrue);
    } finally {
      await temporary.delete(recursive: true);
    }
  });

  test('encrypted operational SRS and bookmarks are live and language scoped', () async {
    final service = UserVaultSecurityService(
      cipher: FakeCipher(), openVaultDatabase: () async => db);
    final first = await service.gradeOperationalSrs(
      lexemeId: 'Haus', languageCode: 'de', grade: 3);
    final second = await service.gradeOperationalSrs(
      lexemeId: 'Haus', languageCode: 'de', grade: 3);
    expect(first.repetitionCount, 1);
    expect(second.repetitionCount, 2);
    expect((await service.readOperationalSrs(
      lexemeId: 'Haus', languageCode: 'fr')), isNull);
    await service.putOperationalBookmark(
      bookmarkId: 'item-1', languageCode: 'tr', data: {'word': 'ev'});
    expect((await service.readOperationalBookmark(
      bookmarkId: 'item-1', languageCode: 'tr'))?['word'], 'ev');
    expect((await service.readOperationalBookmark(
      bookmarkId: 'item-1', languageCode: 'de')), isNull);
    await service.deleteOperationalBookmark(
      bookmarkId: 'item-1', languageCode: 'tr');
    expect(await service.readOperationalBookmark(
      bookmarkId: 'item-1', languageCode: 'tr'), isNull);
    expect((await db.query('vault_entries')).toString(), isNot(contains('Haus')));
  });

  test('migrates all legacy tables to an encrypted, verified snapshot', () async {
    final temporary = await Directory.systemTemp.createTemp('vault-migration-');
    final oldPath = '${temporary.path}/user_progress_v2.db';
    try {
      final legacy = await openDatabase(oldPath, singleInstance: false);
      await legacy.execute('CREATE TABLE srs_progress (lexeme_id TEXT PRIMARY KEY, repetition_count INTEGER)');
      await legacy.execute('CREATE TABLE review_history (id INTEGER PRIMARY KEY, note TEXT, evidence BLOB)');
      await legacy.execute('CREATE TABLE bookmarks (id TEXT PRIMARY KEY, word TEXT)');
      await legacy.insert('srs_progress', {'lexeme_id': 'Haus', 'repetition_count': 4});
      await legacy.insert('review_history', {'id': 1, 'note': 'first review', 'evidence': Uint8List.fromList([0, 255, 7])});
      await legacy.insert('bookmarks', {'id': 'b1', 'word': 'Buch'});
      await legacy.close();

      final service = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
        legacyDatabasePath: () async => oldPath,
      );
      final result = await service.migrateLegacyProgressDatabase();
      expect(result.migrated, isTrue);
      expect(result.tableRowCounts, {
        'bookmarks': 1, 'review_history': 1, 'srs_progress': 1,
      });
      expect(await File(oldPath).exists(), isFalse);
      expect(await File('$oldPath.migrated').exists(), isTrue);

      final manifest = jsonDecode(utf8.decode(
        (await service.readRecord('legacy/v1/manifest'))!,
      )) as Map<String, dynamic>;
      expect(manifest['format'], 'legacy-sqlite-snapshot-v1');
      final rows = await db.query('vault_entries');
      expect(rows, hasLength(9)); // Snapshot, active records, catalogs, ready marker.
      expect(rows.toString(), isNot(contains('Haus')));
      expect(rows.toString(), isNot(contains('Buch')));
      final srs = jsonDecode(utf8.decode(
        (await service.readRecord('legacy/v1/t2/r0'))!,
      )) as Map<String, dynamic>;
      expect(srs['lexeme_id'], 'Haus');
      final history = jsonDecode(utf8.decode(
        (await service.readRecord('legacy/v1/t1/r0'))!,
      )) as Map<String, dynamic>;
      expect(history['evidence'], {'sqlite_blob_b64': 'AP8H'});
      expect(await service.isOperationalActive, isTrue);
      // Simulate a snapshot produced before operational marker support.
      await service.deleteRecord('progress/v1/ready');
      expect(await service.isOperationalActive, isTrue);
      final operational = await service.readOperationalSrs(
        lexemeId: 'Haus', languageCode: 'de');
      expect(operational?['repetition_count'], 4);
      expect((await service.readOperationalBookmark(
        bookmarkId: 'b1', languageCode: 'de'))?['word'], 'Buch');
      final graded = await service.gradeOperationalSrs(
        lexemeId: 'Haus', languageCode: 'de', grade: 3);
      expect(graded.repetitionCount, 5);
      expect((await service.migrateLegacyProgressDatabase()).migrated, isFalse);
    } finally {
      await temporary.delete(recursive: true);
    }
  });

  test('migration failure retains plaintext DB and rolls back vault writes', () async {
    final temporary = await Directory.systemTemp.createTemp('vault-failure-');
    final oldPath = '${temporary.path}/user_progress_v2.db';
    try {
      final legacy = await openDatabase(oldPath, singleInstance: false);
      await legacy.execute('CREATE TABLE bookmarks (id TEXT PRIMARY KEY)');
      await legacy.insert('bookmarks', {'id': 'keep-this'});
      await legacy.close();
      final service = UserVaultSecurityService(
        cipher: BrokenCipher(),
        openVaultDatabase: () async => db,
        legacyDatabasePath: () async => oldPath,
      );
      await expectLater(service.migrateLegacyProgressDatabase(), throwsStateError);
      expect(await File(oldPath).exists(), isTrue);
      expect(await File('$oldPath.migrated').exists(), isFalse);
      expect(await db.query('vault_entries'), isEmpty);
    } finally {
      await temporary.delete(recursive: true);
    }
  });

  test('migration does not overwrite a previous migrated backup', () async {
    final temporary = await Directory.systemTemp.createTemp('vault-existing-');
    final oldPath = '${temporary.path}/user_progress_v2.db';
    try {
      final legacy = await openDatabase(oldPath, singleInstance: false);
      await legacy.execute('CREATE TABLE bookmarks (id TEXT PRIMARY KEY)');
      await legacy.close();
      await File('$oldPath.migrated').writeAsString('original backup', flush: true);
      final service = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
        legacyDatabasePath: () async => oldPath,
      );
      await expectLater(service.migrateLegacyProgressDatabase(), throwsStateError);
      expect(await File(oldPath).exists(), isTrue);
      expect(await File('$oldPath.migrated').readAsString(), 'original backup');
    } finally {
      await temporary.delete(recursive: true);
    }
  });


  test('failed post-encryption verification rolls back the entire vault', () async {
    final temporary = await Directory.systemTemp.createTemp('vault-verify-');
    final oldPath = '${temporary.path}/user_progress_v2.db';
    try {
      final legacy = await openDatabase(oldPath, singleInstance: false);
      await legacy.execute('CREATE TABLE srs_progress (lexeme_id TEXT PRIMARY KEY)');
      await legacy.insert('srs_progress', {'lexeme_id': 'preserve'});
      await legacy.close();
      final service = UserVaultSecurityService(
        cipher: CorruptingCipher(),
        openVaultDatabase: () async => db,
        legacyDatabasePath: () async => oldPath,
      );
      await expectLater(service.migrateLegacyProgressDatabase(), throwsA(isA<Exception>()));
      expect(await db.query('vault_entries'), isEmpty);
      expect(await File(oldPath).exists(), isTrue);
      expect(await File('$oldPath.migrated').exists(), isFalse);
    } finally {
      await temporary.delete(recursive: true);
    }
  });

}
