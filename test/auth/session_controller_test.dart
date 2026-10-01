import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/account_session.dart';
import '../../lib/services/auth_session_controller.dart';
import '../../lib/services/authentication.dart';

class FakeAuthenticationService implements AuthenticationService {
  FakeAuthenticationService(this.session);

  AccountSession session;
  int signOutCalls = 0;

  @override
  Future<AccountSession> get currentSession async => session;

  @override
  Future<AccountSession> signInWithEmailOtp({
    required String email,
    required String otp,
  }) async => session;

  @override
  Future<AccountSession> signInWithGoogle() async => session;

  @override
  Future<AccountSession> signInWithApple() async => session;

  @override
  Future<void> requestEmailOtp({required String email}) async {}

  @override
  Future<AccountSession> renewSession() async => session;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    session = const AccountSession.unauthenticated();
  }
}

void main() {
  test(
    'controller starts unauthenticated and restores a valid session',
    () async {
      final service = FakeAuthenticationService(
        const AccountSession.authenticated(
          identity: AccountIdentity(userId: 'user-1'),
        ),
      );
      final controller = AuthSessionController(service);

      expect(controller.session, const AccountSession.unauthenticated());
      await controller.initialize();

      expect(controller.session.isAuthenticated, isTrue);
      expect(controller.session.identity!.userId, 'user-1');
      expect(controller.isInitialized, isTrue);
    },
  );

  test('session restoration failure stays unauthenticated', () async {
    final service = _ThrowingAuthenticationService();
    final controller = AuthSessionController(service);

    await controller.initialize();

    expect(controller.session, const AccountSession.unauthenticated());
    expect(controller.isInitialized, isTrue);
    expect(controller.lastFailure?.code, AuthenticationFailureCode.unavailable);
  });

  test('logout clears session and does not touch learner repository', () async {
    final service = FakeAuthenticationService(
      const AccountSession.authenticated(
        identity: AccountIdentity(userId: 'user-2'),
      ),
    );
    final controller = AuthSessionController(service);
    await controller.initialize();

    await controller.signOut();

    expect(service.signOutCalls, 1);
    expect(controller.session, const AccountSession.unauthenticated());
  });

  test('failed sign-in does not create an authenticated session', () async {
    final service = _ThrowingAuthenticationService();
    final controller = AuthSessionController(service);
    await controller.initialize();

    await controller.signInWithGoogle();

    expect(controller.session, const AccountSession.unauthenticated());
    expect(controller.lastFailure?.code, AuthenticationFailureCode.unavailable);
  });

  test(
    'successful sign-in updates session without learner-state access',
    () async {
      final service = FakeAuthenticationService(
        const AccountSession.authenticated(
          identity: AccountIdentity(userId: 'user-3'),
        ),
      );
      final controller = AuthSessionController(service);
      await controller.initialize();

      await controller.signInWithGoogle();

      expect(controller.session.identity!.userId, 'user-3');
      expect(controller.lastFailure, isNull);
    },
  );
}

class _ThrowingAuthenticationService implements AuthenticationService {
  @override
  Future<AccountSession> get currentSession async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }

  @override
  Future<AccountSession> signInWithEmailOtp({
    required String email,
    required String otp,
  }) async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }

  @override
  Future<AccountSession> signInWithGoogle() async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }

  @override
  Future<AccountSession> signInWithApple() async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }

  @override
  Future<void> requestEmailOtp({required String email}) async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }

  @override
  Future<AccountSession> renewSession() async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }

  @override
  Future<void> signOut() async {}
}
