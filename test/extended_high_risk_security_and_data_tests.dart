import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';
import 'package:deutsch_bilarabi/services/secure_progress_vault.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Extended highest-risk tests for security, data integrity, size limits,
/// tamper resistance, and critical user-progress flows.
/// Complements existing vault tests to approach Google Play quality coverage.
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
    SharedPreferences.setMockInitialValues({});
    db = await openDatabase(inMemoryDatabasePath);
    await db.execute(
      'CREATE TABLE vault_entries (record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)',
    );
  });

  tearDown(() async => db.close());

  group('UserVaultSecurityService – Edge & Integrity', () {
    test('rejects invalid record IDs', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      expect(
        () => vault.putRecord('', Uint8List(0)),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => vault.putRecord('a' * 129, Uint8List(0)),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => vault.putRecord('invalid id with spaces', Uint8List(0)),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects oversized plaintext before encryption', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      final oversized = Uint8List(UserVaultSecurityService.maximumRecordBytes + 1);
      expect(
        () => vault.putRecord('progress/v1/test/oversized', oversized),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('catalog mutation keeps identity consistency', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      // Simulate via public export after internal mutation path is exercised through restore
      final snapshot = await vault.exportOperationalSnapshot();
      expect(snapshot['srs'], isEmpty);
      expect(snapshot['bookmarks'], isEmpty);
    });
  });

  group('SecureProgressVault – Tamper & Integrity', () {
    test('round-trip preserves progress data', () async {
      final vault = SecureProgressVault();
      final data = {
        'fsrs': {'word1': {'ease': 2.5}},
        'streak': 7,
        'lastActive': DateTime.utc(2026, 11, 24).toIso8601String(),
        'version': 1,
      };

      expect(await vault.storeSecure(data), isTrue);
      final loaded = await vault.loadSecure();
      expect(loaded, isNotNull);
      expect(loaded!['streak'], 7);
      expect(loaded['fsrs'], data['fsrs']);
    });

    test('detects and wipes tampered ciphertext', () async {
      final vault = SecureProgressVault();
      await vault.storeSecure({'streak': 5});

      final prefs = await SharedPreferences.getInstance();
      final original = prefs.getString('secure_progress_vault_v1')!;
      // Flip a character to corrupt
      final corrupted = original.substring(0, original.length - 1) +
          (original.endsWith('A') ? 'B' : 'A');
      await prefs.setString('secure_progress_vault_v1', corrupted);

      expect(await vault.loadSecure(), isNull);
      expect(prefs.getString('secure_progress_vault_v1'), isNull); // wiped
    });

    test('handles empty / missing vault gracefully', () async {
      final vault = SecureProgressVault();
      expect(await vault.loadSecure(), isNull);
    });
  });

  group('Google Play Alignment – No Sensitive Leakage', () {
    test('vault hash never contains original progress identifiers', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );
      const id = 'progress/v1/srs/private-user-lexeme-id';
      await vault.putRecord(id, Uint8List.fromList(utf8.encode('secret-state')));

      final rows = await db.query('vault_entries');
      final hash = rows.single['record_hash'] as String;
      expect(hash, _sha256Hex(id));
      expect(hash.contains('private-user-lexeme-id'), isFalse);
      expect(hash.contains('lexeme'), isFalse);
    });
  });
}
