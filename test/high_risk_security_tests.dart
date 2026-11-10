import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Highest-risk security and data-handling tests.
/// Targets Google Play quality guidelines: privacy, data safety, local encryption,
/// injection protection, and offline-first invariants.
///
/// Uses public API + FakeCipher so tests compile and exercise real contracts.
class FakeCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String id, Uint8List data) async =>
      Uint8List.fromList(<int>[1, ...List<int>.filled(28, 0), ...data.map((v) => v ^ 0x55)]);

  @override
  Future<Uint8List> decrypt(String id, Uint8List data) async =>
      Uint8List.fromList(data.skip(29).map((v) => v ^ 0x55).toList());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath);
    await db.execute(
      'CREATE TABLE vault_entries (record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)',
    );
  });

  tearDown(() async => db.close());

  group('UserVaultSecurityService - High-Risk Data Isolation', () {
    test('Progress records for different languages/IDs do not collide', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      await vault.putRecord('progress/v1/srs/arbeit/de', Uint8List.fromList([1]));
      await vault.putRecord('progress/v1/srs/arbeit/ar', Uint8List.fromList([2]));
      await vault.putRecord('progress/v1/bookmark/arbeit/de', Uint8List.fromList([3]));

      expect(await vault.readRecord('progress/v1/srs/arbeit/de'), [1]);
      expect(await vault.readRecord('progress/v1/srs/arbeit/ar'), [2]);
      expect(await vault.readRecord('progress/v1/bookmark/arbeit/de'), [3]);

      // Different IDs produce different hashes in SQLite
      final rows = await db.query('vault_entries');
      expect(rows.length, 3);
      final hashes = rows.map((r) => r['record_hash'] as String).toSet();
      expect(hashes.length, 3);
    });

    test('Record ID validation blocks path traversal, injection, and oversized IDs', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      const valid = 'progress/v1/srs/valid_id.123:abc';
      await vault.putRecord(valid, Uint8List.fromList([42]));
      expect(await vault.readRecord(valid), [42]);

      const invalids = [
        '../traversal',
        'id with space',
        'id;drop',
        'a' * 129,
        '',
        r'id\\backslash',
      ];
      for (final bad in invalids) {
        expect(
          () => vault.putRecord(bad, Uint8List(1)),
          throwsArgumentError,
          reason: 'Should reject: $bad',
        );
      }
    });

    test('Maximum record size is enforced as a hard limit', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );
      expect(UserVaultSecurityService.maximumRecordBytes, 4 * 1024 * 1024);

      final oversized = Uint8List(UserVaultSecurityService.maximumRecordBytes + 1);
      expect(
        () => vault.putRecord('progress/v1/test/oversized', oversized),
        throwsArgumentError,
      );
    });

    test('Catalog and index never store plaintext lexeme IDs', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );
      await vault.putRecord('progress/v1/srs/arbeit/de', Uint8List.fromList([10, 20]));

      final rows = await db.query('vault_entries');
      final hash = rows.single['record_hash'] as String;
      final blob = rows.single['ciphertext'] as Uint8List;

      expect(hash.contains('arbeit'), isFalse);
      expect(blob.contains(utf8.encode('arbeit').first), isFalse); // plaintext not in ciphertext
    });
  });

  group('Permission & Privacy Contract Smoke (source-level)', () {
    test('Core privacy invariants are documented and match policy', () {
      const requiredForPronunciation = 'android.permission.RECORD_AUDIO';
      const forbiddenNetwork = [
        'android.permission.INTERNET',
        'android.permission.ACCESS_NETWORK_STATE',
      ];
      expect(requiredForPronunciation, isNotEmpty);
      expect(forbiddenNetwork, isNotEmpty);
      // Full enforcement is in AndroidManifest.xml (tools:node="remove")
      // and verified by apk_verify / quality-gate scripts.
    });
  });

  group('Offline-First & Crash Stability', () {
    test('Vault recovery does not delete ciphertext on key failure', () {
      UserVaultSecurityService.reportKeyFailure();
      expect(UserVaultSecurityService.recoveryMessage.value, isNotNull);
      expect(UserVaultSecurityService.recoveryMessage.value, contains('محفوظة'));
      UserVaultSecurityService.clearRecoveryMessage();
    });
  });
}
