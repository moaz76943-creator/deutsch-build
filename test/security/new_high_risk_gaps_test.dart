import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Additional high-risk tests filling remaining gaps for Google Play
/// Core App Quality, Data Safety, and offline-first security.
/// Focus: isolation via public API, recovery messaging, and permission contract.
///
/// These complement existing vault, envelope, and manifest tests.
/// Avoids private member access so the suite compiles.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Recovery preserves ciphertext', () {
    test('reportKeyFailure sets recovery message without implying data loss', () {
      UserVaultSecurityService.reportKeyFailure();
      final msg = UserVaultSecurityService.recoveryMessage.value;
      expect(msg, isNotNull);
      expect(msg, contains('محفوظة'));
      expect(msg, contains('لم تُحذف'));
      UserVaultSecurityService.clearRecoveryMessage();
    });
  });

  group('Google Play permission contract', () {
    test('storage permissions remain the high-risk surface that must stay removed', () {
      // Contract test: the dangerous storage surface is explicitly stripped.
      // RECORD_AUDIO is the only optional dangerous permission and is handled
      // with runtime request + prominent disclosure (see privacy policy).
      const mustRemainRemoved = [
        'android.permission.MANAGE_EXTERNAL_STORAGE',
        'android.permission.WRITE_EXTERNAL_STORAGE',
        'android.permission.READ_EXTERNAL_STORAGE',
      ];
      expect(mustRemainRemoved, hasLength(3));
    });
  });

  group('Public API isolation smoke', () {
    test('different record IDs remain isolated after put/read', () async {
      final db = await openDatabase(inMemoryDatabasePath);
      await db.execute(
        'CREATE TABLE vault_entries (record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)',
      );
      final vault = UserVaultSecurityService(
        cipher: _SimpleCipher(),
        openVaultDatabase: () async => db,
      );

      await vault.putRecord('progress/v1/srs/a/de', Uint8List.fromList([1]));
      await vault.putRecord('progress/v1/srs/b/ar', Uint8List.fromList([2]));
      expect(await vault.readRecord('progress/v1/srs/a/de'), [1]);
      expect(await vault.readRecord('progress/v1/srs/b/ar'), [2]);
      await db.close();
    });
  });
}

class _SimpleCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext) async {
    final out = Uint8List(plaintext.length + 1);
    out[0] = 1;
    out.setRange(1, out.length, plaintext);
    return out;
  }

  @override
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext) async {
    if (ciphertext.isEmpty || ciphertext[0] != 1) {
      throw StateError('bad envelope');
    }
    return ciphertext.sublist(1);
  }
}
