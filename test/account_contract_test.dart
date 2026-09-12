import 'package:flutter_test/flutter_test.dart';

import '../lib/models/account_session.dart';
import '../lib/services/authentication.dart';

class FakeAuthenticationService implements AuthenticationService {
  @override
  Future<AccountSession> get currentSession async =>
      const AccountSession.unauthenticated();

  @override
  Future<AccountSession> signInWithEmailOtp({
    required String email,
    required String otp,
  }) async {
    return const AccountSession.authenticated(
      identity: AccountIdentity(userId: 'user-1'),
    );
  }

  @override
  Future<AccountSession> signInWithGoogle() async {
    return const AccountSession.unauthenticated();
  }

  @override
  Future<AccountSession> signInWithApple() async {
    return const AccountSession.unauthenticated();
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  test('unauthenticated session has no account identity', () {
    const session = AccountSession.unauthenticated();

    expect(session.isAuthenticated, isFalse);
    expect(session.identity, isNull);
    expect(session.expiresAt, isNull);
    expect(session.requiresReauthentication, isFalse);
  });

  test('authenticated session carries canonical account identity only', () {
    const identity = AccountIdentity(userId: 'user-1');
    const session = AccountSession.authenticated(identity: identity);

    expect(session.isAuthenticated, isTrue);
    expect(session.identity, identity);
    expect(session.identity!.userId, 'user-1');
  });

  test('account identity has value semantics', () {
    const first = AccountIdentity(userId: 'user-1');
    const second = AccountIdentity(userId: 'user-1');

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  test('authentication service is provider-neutral', () async {
    final AuthenticationService service = FakeAuthenticationService();

    expect(await service.currentSession,
        const AccountSession.unauthenticated());
    expect(
      await service.signInWithEmailOtp(
        email: 'a@example.com',
        otp: '123456',
      ),
      isA<AccountSession>(),
    );
    expect(await service.signInWithGoogle, isA<AccountSession>());
    expect(await service.signInWithApple, isA<AccountSession>());
    await service.signOut();
  });
}
