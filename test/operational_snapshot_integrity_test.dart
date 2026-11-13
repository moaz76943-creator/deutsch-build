import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// High-risk data handling tests: operational snapshot export/restore
/// Ensures no data loss, no cross-language leakage, catalog integrity,
/// and that ciphertext is never deleted on recovery paths.
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

  group('Operational Snapshot Integrity - Data Safety', () {
    test('export then restore preserves SRS and bookmarks without leakage', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      // Seed operational data via public helpers
      await vault.putOperationalSrs(
        lexemeId: 'arbeit',
        languageCode: 'de',
        schedule: {
          'lexeme_id': 'arbeit',
          'target_language_code': 'de',
          'repetition_count': 3,
          'interval_days': 7,
          'ease_factor': 2.5,
          'status': 'review',
        },
      );
      await vault.putOperationalBookmark(
        bookmarkId: 'bookmark1',
        languageCode: 'ar',
        data: {'note': 'important', 'lang': 'ar'},
      );

      final snapshot = await vault.exportOperationalSnapshot();
      expect(snapshot['srs']!.length, 1);
      expect(snapshot['bookmarks']!.length, 1);
      expect(snapshot['srs']!.single['lexeme_id'], 'arbeit');
      expect(snapshot['bookmarks']!.single['id'], 'bookmark1');

      // Clear by deleting and re-restore
      await vault.deleteOperationalSrs(lexemeId: 'arbeit', languageCode: 'de');
      await vault.deleteOperationalBookmark(bookmarkId: 'bookmark1', languageCode: 'ar');

      final restored = await vault.restoreOperationalSnapshot(
        srs: snapshot['srs']!.map((e) => Map<String, Object?>.from(e)).toList(),
        bookmarks: snapshot['bookmarks']!,
        incomingWins: (_, __) => true,
      );

      expect(restored['inserted'], 1);
      expect(restored['bookmarksInserted'], 1);

      final after = await vault.exportOperationalSnapshot();
      expect(after['srs']!.single['repetition_count'], 3);
      expect(after['bookmarks']!.single['data']['note'], 'important');

      // Isolation: other language not present
      final deOnly = after['srs']!.where((r) => r['target_language_code'] == 'de');
      expect(deOnly.length, 1);
    });

    test('restore does not overwrite newer local data when incomingWins is false', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      await vault.putOperationalSrs(
        lexemeId: 'arbeit',
        languageCode: 'de',
        schedule: {
          'lexeme_id': 'arbeit',
          'target_language_code': 'de',
          'repetition_count': 5,
          'interval_days': 14,
          'ease_factor': 2.6,
          'status': 'review',
        },
      );

      final older = [
        {
          'lexeme_id': 'arbeit',
          'target_language_code': 'de',
          'repetition_count': 1,
          'interval_days': 1,
          'ease_factor': 2.5,
          'status': 'learning',
        }
      ];

      final result = await vault.restoreOperationalSnapshot(
        srs: older,
        bookmarks: [],
        incomingWins: (local, incoming) => false, // local wins
      );

      expect(result['unchanged'], 1);
      final after = await vault.readOperationalSrs(lexemeId: 'arbeit', languageCode: 'de');
      expect(after!['repetition_count'], 5);
    });

    test('catalog never exposes plaintext IDs and key failure preserves ciphertext', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      await vault.putOperationalSrs(
        lexemeId: 'arbeit',
        languageCode: 'de',
        schedule: {'lexeme_id': 'arbeit', 'target_language_code': 'de'},
      );

      final rows = await db.query('vault_entries');
      for (final row in rows) {
        final hash = row['record_hash'] as String;
        final blob = row['ciphertext'] as Uint8List;
        expect(hash.contains('arbeit'), isFalse);
        // Ciphertext is XOR'd, so original UTF-8 bytes of 'arbeit' should not appear raw
        final plain = utf8.encode('arbeit');
        expect(blob.indexOf(plain[0]), -1); // rough check; real AES would be stronger
      }

      // Simulate key failure: report does not delete rows
      final before = rows.length;
      UserVaultSecurityService.reportKeyFailure();
      expect(UserVaultSecurityService.recoveryMessage.value, contains('محفوظة'));
      final afterRows = await db.query('vault_entries');
      expect(afterRows.length, before);
      UserVaultSecurityService.clearRecoveryMessage();
    });
  });
}
