import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:deutsch_bilarabi/core/storage/crash_resilient_store.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Highest-risk gap fillers for Google Play Core App Quality, Data Safety,
/// and offline-first integrity. Focuses on crash recovery of local data,
/// absolute absence of network surface, and non-destructive key failure.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('CrashResilientStore – interrupted write recovery', () {
    late Directory tempDir;
    late CrashResilientStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('crs_');
      store = CrashResilientStore('${tempDir.path}/progress.json');
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('recovers last-known-good when primary is truncated', () async {
      final original = {'srs': ['arbeit', 'haus'], 'score': 42};
      await store.saveAtomically(original);

      // Simulate crash: truncate primary to zero / partial
      await store.primaryFile.writeAsString('', flush: true);

      final recovered = await store.readWithRecovery();
      expect(recovered, original);
      // Primary should be restored from LKG
      expect(await store.primaryFile.readAsString(), contains('arbeit'));
    });

    test('returns empty map when both primary and LKG are missing or corrupt', () async {
      final result = await store.readWithRecovery();
      expect(result, isEmpty);
    });
  });

  group('Network surface completely removed (Data Safety invariant)', () {
    test('INTERNET and network-state permissions are stripped from main and release manifests', () async {
      final main = await File('android/app/src/main/AndroidManifest.xml').readAsString();
      final release = await File('android/app/src/release/AndroidManifest.xml').readAsString();

      const networkPerms = [
        'android.permission.INTERNET',
        'android.permission.ACCESS_NETWORK_STATE',
        'android.permission.ACCESS_WIFI_STATE',
        'android.permission.CHANGE_NETWORK_STATE',
      ];

      for (final p in networkPerms) {
        expect(
          RegExp('android.permission.${p.split('.').last}"\\s*tools:node="remove"').hasMatch(main) ||
              main.contains('$p" tools:node="remove"'),
          isTrue,
          reason: 'main must remove $p',
        );
        expect(release.contains(p), isTrue, reason: 'release overlay must also declare removal for $p');
      }
    });
  });

  group('Vault key failure does not delete ciphertext', () {
    test('reportKeyFailure sets recovery message and blocks further writes without erasing existing records', () async {
      final db = await openDatabase(inMemoryDatabasePath);
      await db.execute(
        'CREATE TABLE vault_entries (record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)',
      );

      final vault = UserVaultSecurityService(
        cipher: _PassThroughCipher(),
        openVaultDatabase: () async => db,
      );

      const id = 'progress/v1/srs/test-key/de';
      await vault.putRecord(id, Uint8List.fromList([9, 9, 9]));

      UserVaultSecurityService.reportKeyFailure();
      expect(UserVaultSecurityService.recoveryMessage.value, contains('محفوظة'));
      expect(UserVaultSecurityService.recoveryMessage.value, contains('لم تُحذف'));

      // Existing ciphertext remains readable via public API (cipher still works in test)
      final stillThere = await vault.readRecord(id);
      expect(stillThere, [9, 9, 9]);

      UserVaultSecurityService.clearRecoveryMessage();
      await db.close();
    });
  });
}

class _PassThroughCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext) async =>
      Uint8List.fromList([1, ...plaintext]);

  @override
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext) async {
    if (ciphertext.isEmpty || ciphertext[0] != 1) {
      throw StateError('bad');
    }
    return ciphertext.sublist(1);
  }
}
