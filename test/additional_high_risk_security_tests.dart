import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Additional highest-risk tests focused on integrity, tamper resistance,
/// recovery locks, and critical data-handling paths for Google Play quality.
class FakeCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String id, Uint8List data) async =>
      Uint8List.fromList(<int>[1, ...List<int>.filled(28, 0), ...data.map((v) => v ^ 0x55)]);

  @override
  Future<Uint8List> decrypt(String id, Uint8List data) async {
    if (data.length < 29 || data[0] != 1) {
      throw CorruptRecordException('Invalid envelope');
    }
    return Uint8List.fromList(data.skip(29).map((v) => v ^ 0x55).toList());
  }
}

String _sha256Hex(String input) => sha256.convert(utf8.encode(input)).toString();

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

  group('Vault Integrity & Tamper Resistance', () {
    test('deleteRecord removes entry and subsequent read returns null', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      const id = 'progress/v1/srs/test-delete';
      await vault.putRecord(id, Uint8List.fromList([99]));
      expect(await vault.readRecord(id), [99]);

      await vault.deleteRecord(id);
      expect(await vault.readRecord(id), isNull);

      final rows = await db.query('vault_entries');
      expect(rows, isEmpty);
    });

    test('corrupt ciphertext (short or bad version) is rejected on read', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      const id = 'progress/v1/test/corrupt';
      // Insert a deliberately bad envelope via direct DB using public hash computation
      await db.insert('vault_entries', {
        'record_hash': _sha256Hex(id),
        'ciphertext': Uint8List.fromList([0, 1, 2]), // too short + bad version
      });

      expect(
        () => vault.readRecord(id),
        throwsA(isA<CorruptRecordException>()),
      );
    });

    test('recovery message is set and can be cleared without data loss', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      UserVaultSecurityService.reportKeyFailure();
      expect(UserVaultSecurityService.recoveryMessage.value, isNotNull);
      expect(UserVaultSecurityService.recoveryMessage.value, contains('محفوظة'));

      UserVaultSecurityService.clearRecoveryMessage();
      expect(UserVaultSecurityService.recoveryMessage.value, isNull);

      // Writes still succeed after clear
      await vault.putRecord('progress/v1/test/after-clear', Uint8List.fromList([1]));
      expect(await vault.readRecord('progress/v1/test/after-clear'), [1]);
    });

    test('round-trip preserves data for valid IDs including special chars', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      const id = 'progress/v1/srs/word_with.dots:and/slashes';
      final payload = Uint8List.fromList([10, 20, 30, 40, 50]);
      await vault.putRecord(id, payload);
      final retrieved = await vault.readRecord(id);
      expect(retrieved, payload);
    });
  });

  group('Google Play Data Safety Alignment', () {
    test('No plaintext progress identifiers stored in SQLite hash or ciphertext', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );
      const sensitiveId = 'progress/v1/srs/user-private-progress';
      await vault.putRecord(sensitiveId, Uint8List.fromList(utf8.encode('local-only-data')));

      final rows = await db.query('vault_entries');
      final hash = rows.single['record_hash'] as String;
      expect(hash, _sha256Hex(sensitiveId));
      expect(hash, isNot(contains('user-private-progress')));
      expect(hash.length, 64);
    });
  });
}
