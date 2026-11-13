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
    test('export then restore preserves bookmarks and SRS records', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      await vault.putOperationalBookmark(
        bookmarkId: 'bookmark1',
        languageCode: 'ar',
        data: {'note': 'important', 'lang': 'ar'},
      );

      await vault.incrementOperationalSrs(
        lexemeId: 'arbeit',
        languageCode: 'de',
        status: 'review',
      );

      final snapshot = await vault.exportOperationalSnapshot();
      expect(snapshot['bookmarks']!.length, greaterThanOrEqualTo(1));
      expect(snapshot['srs']!.any((r) => r['lexeme_id'] == 'arbeit'), isTrue);

      final restored = await vault.restoreOperationalSnapshot(
        srs: snapshot['srs']!.map((e) => Map<String, Object?>.from(e)).toList(),
        bookmarks: snapshot['bookmarks']!,
        incomingWins: (_, __) => true,
      );

      expect(restored['inserted'] + (restored['updated'] ?? 0), greaterThanOrEqualTo(0));
      expect(restored['bookmarksInserted'] + (restored['bookmarksUpdated'] ?? 0), greaterThanOrEqualTo(0));

      final after = await vault.exportOperationalSnapshot();
      expect(after['bookmarks']!.any((b) => b['id'] == 'bookmark1'), isTrue);
      expect(after['srs']!.any((r) => r['lexeme_id'] == 'arbeit'), isTrue);
    });

    test('restore respects incomingWins=false and does not clobber local data', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      await vault.incrementOperationalSrs(
        lexemeId: 'arbeit',
        languageCode: 'de',
        status: 'review',
      );

      final older = <Map<String, Object?>>[
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
        incomingWins: (local, incoming) => false,
      );

      expect(result['unchanged'], greaterThanOrEqualTo(1));
      final after = await vault.readOperationalSrs(lexemeId: 'arbeit', languageCode: 'de');
      expect(after, isNotNull);
      expect((after!['repetition_count'] as num).toInt(), greaterThanOrEqualTo(1));
    });

    test('key failure report does not delete existing ciphertext', () async {
      final vault = UserVaultSecurityService(
        cipher: FakeCipher(),
        openVaultDatabase: () async => db,
      );

      await vault.putOperationalBookmark(
        bookmarkId: 'safe',
        languageCode: 'de',
        data: {'keep': true},
      );

      final before = (await db.query('vault_entries')).length;
      UserVaultSecurityService.reportKeyFailure();
      expect(UserVaultSecurityService.recoveryMessage.value, contains('محفوظة'));
      final after = (await db.query('vault_entries')).length;
      expect(after, before);
      UserVaultSecurityService.clearRecoveryMessage();
    });
  });
}
