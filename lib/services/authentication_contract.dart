import '../models/account_session.dart';
import '../models/backend_authentication_contract.dart';
import '../models/secure_session_credentials.dart';

/// Email OTP adapter. It owns no persistent credential state.
abstract interface class EmailOtpProvider {
  Future<void> requestCode({required String email});

  Future<AccountSession> verifyCode({
    required String email,
    required String otp,
  });
}

/// Social provider adapter for Google or Apple.
abstract interface class SocialAuthenticationProvider {
  AccountProvider get provider;

  Future<ProviderAuthenticationAssertion> authenticate();
}

/// Provider-neutral authentication boundary.
abstract interface class BackendAuthenticationGateway {
  Future<void> requestEmailOtp(EmailOtpRequest request);

  Future<AccountSession> verifyEmailOtp(EmailOtpVerification request);

  Future<AccountSession> authenticateProvider(
    ProviderAuthenticationAssertion assertion,
  );

  Future<AccountSession> renewSession(SecureSessionCredentials credentials);

  Future<void> revokeSession(SecureSessionCredentials? credentials);

  Future<AccountSession> getCurrentSession();

  Future<void> signOut();
}

abstract interface class AuthenticationService {
  Future<AccountSession> get currentSession;

  Future<void> requestEmailOtp({required String email});

  Future<AccountSession> signInWithEmailOtp({
    required String email,
    required String otp,
  });

  Future<AccountSession> signInWithGoogle();

  Future<AccountSession> signInWithApple();

  Future<AccountSession> renewSession();

  Future<void> signOut();
}
