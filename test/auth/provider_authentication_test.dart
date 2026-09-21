import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/account_session.dart';
import '../../lib/models/backend_authentication_contract.dart';
import '../../lib/models/secure_session_credentials.dart';
import '../../lib/services/authentication.dart';
import '../../lib/services/authentication_providers.dart';

class FakeOtpProvider implements EmailOtpProvider {
  FakeOtpProvider({this.session, this.error});

  final AccountSession? session;
  final Object? error;

  @override
  Future<void> requestCode({required String email}) async {
    if (error != null) throw error!;
  }

  @override
  Future<AccountSession> verifyCode({
    required String email,
    required String otp,
  }) async {
    if (error != null) throw error!;
    return session ?? const AccountSession.unauthenticated();
  }
}

class FakeSocialProvider implements SocialAuthenticationProvider {
  FakeSocialProvider(this.provider, this.result);

  @override
  final AccountProvider provider;
  final AccountSession result;

  @override
  Future<ProviderAuthenticationAssertion> authenticate() async =>
      ProviderAuthenticationAssertion(
        provider: provider,
        assertion: result.identity?.userId ?? 'provider-assertion',
      );
}

class FakeBackendAuthenticationGateway
    implements BackendAuthenticationGateway {
  FakeBackendAuthenticationGateway({
    this.google = const AccountSession.unauthenticated(),
    this.apple = const AccountSession.unauthenticated(),
    this.email = const AccountSession.unauthenticated(),
    this.current = const AccountSession.unauthenticated(),
    this.emailError,
  });

  final AccountSession google;
  final AccountSession apple;
  final AccountSession email;
  final AccountSession current;
  final Object? emailError;
  final List<ProviderAuthenticationAssertion> providerAssertions =
      <ProviderAuthenticationAssertion>[];

  @override
  Future<void> requestEmailOtp(EmailOtpRequest request) async {}

  @override
  Future<AccountSession> verifyEmailOtp(EmailOtpVerification request) async {
    if (emailError != null) throw emailError!;
    return email;
  }

  @override
  Future<AccountSession> authenticateProvider(
    ProviderAuthenticationAssertion assertion,
  ) async {
    providerAssertions.add(assertion);
    return assertion.provider == AccountProvider.google ? google : apple;
  }

  @override
  Future<AccountSession> getCurrentSession() async => current;

  @override
  Future<AccountSession> renewSession(
    SecureSessionCredentials credentials,
  ) async =>
      current;

  @override
  Future<void> revokeSession(SecureSessionCredentials? credentials) async {}

  @override
  Future<void> signOut() async {}
}

ProviderAuthenticationService serviceWith({
  EmailOtpProvider? email,
  AccountSession? google,
  AccountSession? apple,
  BackendAuthenticationGateway? backend,
}) {
  final emailProvider = email ?? FakeOtpProvider();
  final resolvedBackend = backend ??
      FakeBackendAuthenticationGateway(
        email: emailProvider is FakeOtpProvider
            ? emailProvider.session ?? const AccountSession.unauthenticated()
            : const AccountSession.unauthenticated(),
        google: google ?? const AccountSession.unauthenticated(),
        apple: apple ?? const AccountSession.unauthenticated(),
      );
  return ProviderAuthenticationService(
    emailOtpProvider: emailProvider,
    googleProvider: FakeSocialProvider(
      AccountProvider.google,
      google ?? const AccountSession.unauthenticated(),
    ),
    appleProvider: FakeSocialProvider(
      AccountProvider.apple,
      apple ?? const AccountSession.unauthenticated(),
    ),
    backendGateway: resolvedBackend,
  );
}

void main() {
  test('invalid or expired OTP stays unauthenticated', () async {
    final provider = FakeOtpProvider(
      error: const AuthenticationFailure(
        AuthenticationFailureCode.invalidCredential,
      ),
    );
    final service = serviceWith(
      email: provider,
      backend: FakeBackendAuthenticationGateway(
        emailError: const AuthenticationFailure(
          AuthenticationFailureCode.invalidCredential,
        ),
      ),
    );

    expect(
      () => service.signInWithEmailOtp(
        email: 'a@example.com',
        otp: '123456',
      ),
      throwsA(isA<AuthenticationFailure>()),
    );
    expect(
      await service.currentSession,
      const AccountSession.unauthenticated(),
    );
  });

  test('successful OTP exposes only the canonical account identity', () async {
    final service = serviceWith(
      email: FakeOtpProvider(
        session: const AccountSession.authenticated(
          identity: AccountIdentity(userId: 'user-42'),
        ),
      ),
    );

    final result = await service.signInWithEmailOtp(
      email: 'a@example.com',
      otp: '123456',
    );

    expect(result.identity!.userId, 'user-42');
    expect(result.isAuthenticated, isTrue);
    expect(result.expiresAt, isNull);
  });

  test('Google and Apple are independent adapters', () async {
    final service = serviceWith(
      google: const AccountSession.authenticated(
        identity: AccountIdentity(userId: 'google-user'),
      ),
      apple: const AccountSession.authenticated(
        identity: AccountIdentity(userId: 'apple-user'),
      ),
    );

    expect((await service.signInWithGoogle()).identity!.userId, 'google-user');
    await service.signOut();
    expect((await service.signInWithApple()).identity!.userId, 'apple-user');
  });

  test('provider cancellation does not fabricate a session', () async {
    final service = serviceWith();

    expect(
      await service.signInWithGoogle(),
      const AccountSession.unauthenticated(),
    );
    expect(
      await service.currentSession,
      const AccountSession.unauthenticated(),
    );
  });

  test('unavailable adapters fail closed', () async {
    final service = ProviderAuthenticationService(
      emailOtpProvider: const UnavailableEmailOtpProvider(),
      googleProvider: const UnavailableSocialAuthenticationProvider(
        AccountProvider.google,
      ),
      appleProvider: const UnavailableSocialAuthenticationProvider(
        AccountProvider.apple,
      ),
    );

    expect(
      () => service.signInWithGoogle(),
      throwsA(isA<AuthenticationFailure>()),
    );
    expect(
      () => service.signInWithApple(),
      throwsA(isA<AuthenticationFailure>()),
    );
    expect(
      () => service.signInWithEmailOtp(email: 'a@example.com', otp: '123456'),
      throwsA(isA<AuthenticationFailure>()),
    );
    expect(
      await service.currentSession,
      const AccountSession.unauthenticated(),
    );
  });

  test('expired authenticated session becomes unauthenticated', () async {
    final service = serviceWith(
      google: AccountSession.authenticated(
        identity: const AccountIdentity(userId: 'expired-user'),
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      ),
    );

    await service.signInWithGoogle();
    expect(
      await service.currentSession,
      const AccountSession.unauthenticated(),
    );
  });

  test('sign out clears session without touching learner state', () async {
    final service = serviceWith(
      google: const AccountSession.authenticated(
        identity: AccountIdentity(userId: 'user-7'),
      ),
    );

    await service.signInWithGoogle();
    await service.signOut();

    expect(
      await service.currentSession,
      const AccountSession.unauthenticated(),
    );
  });
}
