import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/account_session.dart';
import '../../lib/models/backend_authentication_api.dart';
import '../../lib/models/secure_session_credentials.dart';

void main() {
  test('backend response can carry only an opaque session credential', () {
    final credentials = SecureSessionCredentials('opaque');
    final response = BackendAuthenticationApiResponse(
      session: AccountSession.authenticated(
        identity: AccountIdentity(userId: 'u1'),
      ),
      credentials: credentials,
    );

    expect(response.credentials?.value, 'opaque');
    expect(response.session?.identity?.userId, 'u1');
  });

  test('credential is not part of AccountSession', () {
    const session = AccountSession.authenticated(
      identity: AccountIdentity(userId: 'u1'),
    );
    expect(session.isAuthenticated, isTrue);
    expect(session.identity?.userId, 'u1');
  });
}
