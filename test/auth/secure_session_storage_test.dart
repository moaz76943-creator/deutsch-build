import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/secure_session_credentials.dart';
import '../../lib/services/secure_session_storage.dart';

void main() {
  test('credentials remain opaque', () {
    const credentials = SecureSessionCredentials('ephemeral');
    expect(credentials.value, 'ephemeral');
  });

  test('unavailable storage never persists credentials', () async {
    const storage = UnavailableSecureSessionStorage();
    expect(await storage.read(), isNull);
    await storage.clear();
  });

  test('unavailable storage rejects save', () async {
    const storage = UnavailableSecureSessionStorage();
    expect(
      storage.save(const SecureSessionCredentials('ephemeral')),
      throwsA(isA<StateError>()),
    );
  });
}
