import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Additional highest-risk tests targeting remaining gaps in data handling,
/// recovery safety, size limits, and concurrent isolation for Google Play
/// Core App Quality, Data Safety, and offline-first integrity.
///
/// Complements existing vault, envelope, manifest, and privacy tests.
/// Uses only public API + FakeCipher so the suite remains stable.
class _XorCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String id, Uint8List data) async =>
      Uint8List.fromList(<int>[1, ...List<int>.filled(28, 0), ...data.map((v) => v ^ 0xA5)]);

  @override
  Future<Uint8List> decrypt(String id, Uint8List data) async {
    if (data.length < 29 || data[0] != 1) {
      throw CorruptRecordException('Invalid envelope');
    }
    return Uint8List.fromList(data.skip(29).map((v) => v ^ 0xA5).toList());
  }
}

String _hash(String id) => sha256.convert(utf8.encode(id)).toString();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late UserVaultSecurityService vault;

  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath);
    await db.execute(
      'CREATE TABLE vault_entries (record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)',
    );
    vault = UserVaultSecurityService(
      cipher: _XorCipher(),
      openVaultDatabase: () async => db,
    );
  });

  tearDown(() async => db.close());

  group('Size limits and input bounds (Google Play data safety)', () {
    test('rejects records larger than maximumRecordBytes', () async {
      final oversized = Uint8List(UserVaultSecurityService.maximumRecordBytes + 1);
      expect(
        () => vault.putRecord('progress/v1/srs/big', oversized),
        throwsArgumentError,
      );
    });

    test('accepts record at exact maximum size', () async {
      final max = Uint8List(UserVaultSecurityService.maximumRecordBytes);
      await vault.putRecord('progress/v1/srs/max', max);
      final read = await vault.readRecord('progress/v1/srs/max');
      expect(read, isNotNull);
      expect(read!.length, UserVaultSecurityService.maximumRecordBytes);
    });

    test('rejects empty and path-like IDs that could enable traversal', () async {
      const badIds = ['', '../etc/passwd', 'id/../../secret', 'a' * 129];
      for (final id in badIds) {
        expect(
          () => vault.putRecord(id, Uint8List(1)),
          throwsArgumentError,
          reason: 'ID "\$id" must be rejected',
        );
      }
    });
  });

  group('Concurrent isolation and replace semantics', () {
    test('concurrent puts of different IDs do not corrupt each other', () async {
      final futures = <Future>[];
      for (var i = 0; i < 20; i++) {
        futures.add(vault.putRecord(
          'progress/v1/srs/item\$i',
          Uint8List.fromList([i]),
        ));
      }
      await Future.wait(futures);

      for (var i = 0; i < 20; i++) {
        final data = await vault.readRecord('progress/v1/srs/item\$i');
        expect(data, [i]);
      }

      final rows = await db.query('vault_entries');
      expect(rows.length, 20);
    });

    test('replace on same ID overwrites previous ciphertext', () async {
      await vault.putRecord('progress/v1/srs/same', Uint8List.fromList([1]));
      await vault.putRecord('progress/v1/srs/same', Uint8List.fromList([2, 3]));
      final data = await vault.readRecord('progress/v1/srs/same');
      expect(data, [2, 3]);

      final rows = await db.query('vault_entries');
      expect(rows.length, 1);
    });
  });

  group('Corrupt envelope rejection', () {
    test('short ciphertext is rejected on read', () async {
      await db.insert('vault_entries', {
        'record_hash': _hash('progress/v1/srs/short'),
        'ciphertext': Uint8List(10),
      });
      expect(
        () => vault.readRecord('progress/v1/srs/short'),
        throwsA(isA<CorruptRecordException>()),
      );
    });

    test('wrong version byte is rejected', () async {
      await db.insert('vault_entries', {
        'record_hash': _hash('progress/v1/srs/badver'),
        'ciphertext': Uint8List.fromList([9, ...List.filled(28, 0), 1]),
      });
      expect(
        () => vault.readRecord('progress/v1/srs/badver'),
        throwsA(isA<CorruptRecordException>()),
      );
    });
  });

  group('Recovery messaging contract', () {
    test('reportKeyFailure sets non-empty Arabic recovery message that preserves data', () {
      UserVaultSecurityService.reportKeyFailure();
      final msg = UserVaultSecurityService.recoveryMessage.value;
      expect(msg, isNotNull);
      expect(msg!.contains('\u0645\u062d\u0641\u0648\u0638\u0629'), isTrue);
      expect(msg.contains('\u0644\u0645 \u062a\u064f\u062d\u0630\u0641'), isTrue);
      UserVaultSecurityService.clearRecoveryMessage();
      expect(UserVaultSecurityService.recoveryMessage.value, isNull);
    });
  });
}
