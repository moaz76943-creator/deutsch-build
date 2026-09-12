import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/account_session.dart';
import '../../lib/models/backend_authentication_contract.dart';
import '../../lib/services/authentication.dart';
import '../../lib/services/authentication_providers.dart';

class FakeBackendGateway implements BackendAuthenticationGateway {
  FakeBackendGateway({this.session = const AccountSession.unauthenticated()});

  final AccountSession session;
  final List<ProviderAuthenticationAssertion> providerAssertions =
      <ProviderAuthenticationAssertion>[];
  EmailOtpVerification? otpVerification;

  @override
  Future<void> requestEmailOtp(EmailOtpRequest request) async {}

  @override
  Future<AccountSession> verifyEmailOtp(EmailOtpVerification request) async {
    otpVerification = request;
    return session;
  }

  @override
  Future<AccountSession> authenticateProvider(
    ProviderAuthenticationAssertion assertion,
  ) async {
    providerAssertions.add(assertion);
    return session;
  }

  @override
  Future<AccountSession> getCurrentSession() async => session;

  @override
  Future<void> signOut() async {}
}

class FakeGoogleProvider implements SocialAuthenticationProvider {
  @override
  AccountProvider get provider => AccountProvider.google;

  @override
  Future<ProviderAuthenticationAssertion> authenticate() async =>
      const ProviderAuthenticationAssertion(
        provider: AccountProvider.google,
        assertion: 'ephemeral-assertion',
      );
}

class FakeAppleProvider implements SocialAuthenticationProvider {
  @override
  AccountProvider get provider => AccountProvider.apple;

  @override
  Future<ProviderAuthenticationAssertion> authenticate() async =>
      const ProviderAuthenticationAssertion(
        provider: AccountProvider.apple,
        assertion: 'ephemeral-apple-assertion',
      );
}

class FakeEmailProvider implements EmailOtpProvider {
  @override
  Future<void> requestCode({required String email}) async {}

  @override
  Future<AccountSession> verifyCode({
    required String email,
    required String otp,
  }) async =>
      const AccountSession.unauthenticated();
}

void main() {
  test('backend failure categories are stable and provider-neutral', () {
    expect(
      BackendAuthenticationFailureCode.values,
      containsAll(<BackendAuthenticationFailureCode>[
        BackendAuthenticationFailureCode.invalidAuthentication,
        BackendAuthenticationFailureCode.rateLimited,
        BackendAuthenticationFailureCode.providerRejected,
        BackendAuthenticationFailureCode.unavailable,
        BackendAuthenticationFailureCode.invalidSession,
        BackendAuthenticationFailureCode.retryable,
      ]),
    );
  });

  test('provider assertion carries only provider and transient assertion', () {
    const credential = ProviderAuthenticationAssertion(
      provider: AccountProvider.google,
      assertion: 'ephemeral-assertion',
    );
    expect(credential.provider, AccountProvider.google);
    expect(credential.assertion, 'ephemeral-assertion');
  });

  test('backend authenticated session exposes only AccountSession', () {
    const result = BackendAuthenticatedSession(
      AccountSession.authenticated(
        identity: AccountIdentity(userId: 'internal-user'),
      ),
    );
    expect(result.session.identity?.userId, 'internal-user');
    expect(result.session.isAuthenticated, isTrue);
  });

  test('Google assertion is delegated to backend for canonical session', () async {
    final gateway = FakeBackendGateway(
      session: const AccountSession.authenticated(
        identity: AccountIdentity(userId: 'internal-user'),
      ),
    );
    final service = ProviderAuthenticationService(
      emailOtpProvider: FakeEmailProvider(),
      googleProvider: FakeGoogleProvider(),
      appleProvider: FakeAppleProvider(),
      backendGateway: gateway,
    );

    final session = await service.signInWithGoogle();

    expect(session.identity?.userId, 'internal-user');
    expect(gateway.providerAssertions.single.provider, AccountProvider.google);
    expect(gateway.providerAssertions.single.assertion, 'ephemeral-assertion');
  });

  test('Email OTP verification is delegated to backend', () async {
    final gateway = FakeBackendGateway(
      session: const AccountSession.authenticated(
        identity: AccountIdentity(userId: 'email-user'),
      ),
    );
    final service = ProviderAuthenticationService(
      emailOtpProvider: FakeEmailProvider(),
      googleProvider: FakeGoogleProvider(),
      appleProvider: FakeAppleProvider(),
      backendGateway: gateway,
    );

    final session = await service.signInWithEmailOtp(
      email: 'a@example.com',
      otp: '123456',
    );

    expect(session.identity?.userId, 'email-user');
    expect(gateway.otpVerification?.email, 'a@example.com');
    expect(gateway.otpVerification?.otp, '123456');
  });

  test('unavailable backend remains fail-closed', () async {
    const gateway = UnavailableBackendAuthenticationGateway();
    expect(
      gateway.authenticateProvider(
        const ProviderAuthenticationAssertion(
          provider: AccountProvider.google,
          assertion: 'ephemeral-assertion',
        ),
      ),
      throwsA(isA<AuthenticationFailure>()),
    );
  });
}
