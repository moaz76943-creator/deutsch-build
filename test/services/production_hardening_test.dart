
import 'package:deutsch_bilarabi/services/fts_search_service.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
  });

  test('FTS5-unavailable pack falls back to parameterized LIKE', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await db.execute('''
      CREATE TABLE lexicon (
        id TEXT PRIMARY KEY,
        surface TEXT NOT NULL,
        part_of_speech TEXT NOT NULL,
        fields_json TEXT NOT NULL
      )
    ''');
    await db.insert('lexicon', {
      'id': 'en-1',
      'surface': 'book',
      'part_of_speech': 'noun',
      'fields_json':
          '{"translations":[{"languageCode":"ar","text":"كتاب"}]}',
    });

    // No lexicon_fts table: the MATCH query must fail and LIKE must recover.
    final results = await FtsSearchService().searchDatabase(
      db, 'boo', languageCode: 'en',
    );
    expect(results, hasLength(1));
    expect(results.single['surface'], 'book');
    expect(results.single['translation_ar'], 'كتاب');
    expect(results.single['translation_language_code'], 'ar');
  });

  test('unavailable Android Keystore preserves records and shows warning', () async {
    const channel = MethodChannel('com.deutschbilarabi.app/user_vault_security');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'vault_key_unavailable_or_corrupt');
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
      UserVaultSecurityService.clearRecoveryMessage();
    });

    const cipher = AndroidKeystoreVaultCipher();
    await expectLater(
      cipher.decrypt('progress/v1/ready', Uint8List.fromList(List.filled(29, 0))),
      throwsA(isA<PlatformException>()),
    );
    expect(UserVaultSecurityService.recoveryMessage.value, isNotNull);
    expect(UserVaultSecurityService.recoveryMessage.value,
        contains('لم تُحذف'));

    // Writes must remain blocked after a key failure, even if UI dismisses
    // the message. Only verified successful decryption clears this state.
    UserVaultSecurityService.clearRecoveryMessage();
    await expectLater(
      cipher.encrypt('progress/v1/ready', Uint8List.fromList([1])),
      throwsStateError,
    );
    messenger.setMockMethodCallHandler(channel, (call) async {
      return Uint8List.fromList([1]);
    });
    await cipher.decrypt('progress/v1/ready',
        Uint8List.fromList(List.filled(29, 0)));
    expect(UserVaultSecurityService.recoveryMessage.value, isNull);
  });
}
