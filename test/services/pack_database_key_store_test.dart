import 'dart:convert';

import 'package:deutsch_bilarabi/services/pack_database_key_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Android key store adapter accepts exactly 256-bit base64 material',
      () async {
    const channel = MethodChannel(
      'com.deutschbilarabi.app/pack_database_key_store',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'read') {
        return base64Encode(List<int>.generate(32, (index) => index));
      }
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final store = AndroidKeystorePackDatabaseKeyStore(channel: channel);
    final key = await store.readKey();

    expect(base64Decode(key!), hasLength(32));
  });

  test('malformed platform key fails closed', () async {
    const channel = MethodChannel(
      'com.deutschbilarabi.app/pack_database_key_store',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async => 'not-a-key');
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final store = AndroidKeystorePackDatabaseKeyStore(channel: channel);

    await expectLater(
      store.readKey(),
      throwsA(isA<PackDatabaseKeyStoreException>()),
    );
  });
}
