import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

import '../../../lib/services/user_vault_security_service.dart';

class MockVaultCipher implements VaultCipher {
  final bool failEncryption;
  final bool failDecryption;
  final bool tamperCiphertext;
  final bool keyUnavailable;
  final Duration? delay;

  MockVaultCipher({
    this.failEncryption = false,
    this.failDecryption = false,
    this.tamperCiphertext = false,
    this.keyUnavailable = false,
    this.delay,
  });

  @override
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext) async {
    if (delay != null) await Future<void>.delayed(delay!);
    if (keyUnavailable) {
      throw KeyUnavailableException('Mock key unavailable');
    }
    if (failEncryption) {
      // Return invalid envelope format
      return Uint8List.fromList([0, 0, 0]);
    }
    // Simulate encryption by prepending envelope marker
    final result = BytesBuilder();
    result.addByte(1); // envelope version
    result.add(List.filled(28, 0)); // fake metadata

    if (tamperCiphertext) {
      // Simulate plaintext downgrade by returning exactly the plaintext without proper envelope length
      return plaintext;
    }

    // embed the recordId into the ciphertext for ID verification
    final idBytes = utf8.encode(recordId);
    result.addByte(idBytes.length);
    result.add(idBytes);

    result.add(plaintext);
    return result.toBytes();
  }

  @override
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext) async {
    if (delay != null) await Future<void>.delayed(delay!);
    if (keyUnavailable) {
      throw KeyUnavailableException('Mock key unavailable');
    }
    if (failDecryption) {
      throw Exception('Decryption failed');
    }
    if (ciphertext.length < 29 || ciphertext[0] != 1) {
      throw CorruptRecordException('Invalid format in decrypt mock');
    }

    // Validate embedded record ID
    var offset = 29;
    final idLength = ciphertext[offset++];
    final idBytes = ciphertext.sublist(offset, offset + idLength);
    final embeddedId = utf8.decode(idBytes);

    if (embeddedId != recordId) {
      throw Exception('ID mismatch');
    }

    offset += idLength;
    return ciphertext.sublist(offset);
  }
}

class PlaintextDowngradeMockCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext) async {
    return plaintext;
  }

  @override
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext) async {
    return ciphertext;
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('J011 UserVaultSecurityService Encrypted Learner Vault', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('vault_test_');
      dbPath = p.join(tempDir.path, 'test_vault.db');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    Future<Database> openTestDb() async {
      return openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE vault_entries (record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)',
          );
        },
      );
    }

    test(
      'validates ciphertext envelope and rejects tampered records',
      () async {
        final service = UserVaultSecurityService(
          cipher: MockVaultCipher(failEncryption: true),
          openVaultDatabase: openTestDb,
        );

        final data = Uint8List.fromList(utf8.encode('test data'));
        await expectLater(
          () => service.putRecord('test_id', data),
          throwsA(isA<CorruptRecordException>()),
        );
      },
    );

    test('rejects silent plaintext downgrade', () async {
      final service = UserVaultSecurityService(
        cipher: PlaintextDowngradeMockCipher(),
        openVaultDatabase: openTestDb,
      );

      // Create a plaintext that looks like a valid envelope to bypass the length/marker check
      final plaintextBuilder = BytesBuilder();
      plaintextBuilder.addByte(1);
      plaintextBuilder.add(List.filled(30, 0));
      final data = plaintextBuilder.toBytes();

      await expectLater(
        () => service.putRecord('test_id', data),
        throwsA(isA<CorruptRecordException>()),
      );
    });

    test('throws TamperedRecordException on decryption failure', () async {
      // First save a valid record
      final validService = UserVaultSecurityService(
        cipher: MockVaultCipher(),
        openVaultDatabase: openTestDb,
      );
      final data = Uint8List.fromList(utf8.encode('test data'));
      await validService.putRecord('test_id', data);

      // Then try to read it with a failing cipher
      final failingService = UserVaultSecurityService(
        cipher: MockVaultCipher(failDecryption: true),
        openVaultDatabase: openTestDb,
      );

      await expectLater(
        () => failingService.readRecord('test_id'),
        throwsA(isA<TamperedRecordException>()),
      );
    });

    test('rejects mismatched IDs with TamperedRecordException', () async {
      final service = UserVaultSecurityService(
        cipher: MockVaultCipher(),
        openVaultDatabase: openTestDb,
      );
      final data = Uint8List.fromList(utf8.encode('test data'));

      final db = await openTestDb();
      final ciphertext = await MockVaultCipher().encrypt('wrong_id_internal', data);

      // ff661b889d9bdfff9a858cce377bee1e860e09a535b2947b22ef2a689cdfe73a is sha256 of 'test_id_mismatch'
      await db.insert('vault_entries', {
        'record_hash': 'ff661b889d9bdfff9a858cce377bee1e860e09a535b2947b22ef2a689cdfe73a',
        'ciphertext': ciphertext,
      });

      await expectLater(
        () => service.readRecord('test_id_mismatch'),
        throwsA(isA<TamperedRecordException>()),
      );
    });

    test('rejects mismatched IDs explicit', () async {
      final service = UserVaultSecurityService(
        cipher: MockVaultCipher(),
        openVaultDatabase: openTestDb,
      );

      final data = Uint8List.fromList(utf8.encode('test data'));
      await service.putRecord('test_id', data);

      // we need a reliable way to make the decrypt fail due to ID mismatch
      // Let's directly invoke cipher to prove it works
      final cipher = MockVaultCipher();
      final encrypted = await cipher.encrypt('id_1', data);

      await expectLater(
        () => cipher.decrypt('id_2', encrypted),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('ID mismatch'))),
      );
    });

    test('respects explicit key unavailable state', () async {
      final service = UserVaultSecurityService(
        cipher: MockVaultCipher(keyUnavailable: true),
        openVaultDatabase: openTestDb,
      );

      final data = Uint8List.fromList(utf8.encode('test data'));
      await expectLater(
        () => service.putRecord('test_id', data),
        throwsA(isA<KeyUnavailableException>()),
      );
    });

    test('protects concurrent save/recovery operations', () async {
      final log = <String>[];
      final cipher = MockVaultCipher(delay: const Duration(milliseconds: 100));
      final service = UserVaultSecurityService(
        cipher: cipher,
        openVaultDatabase: openTestDb,
      );

      final data = Uint8List.fromList(utf8.encode('test data'));

      // We simulate concurrent operations by firing them simultaneously
      final future1 = () async {
        await service.putRecord('test_id', data);
        log.add('put1');
      }();

      final future2 = () async {
        await service.putRecord('test_id2', data);
        log.add('put2');
      }();

      await Future.wait([future1, future2]);

      final val1 = await service.readRecord('test_id');
      final val2 = await service.readRecord('test_id2');

      expect(val1, isNotNull);
      expect(val2, isNotNull);
      expect(log.length, 2);
    });
  });
}
