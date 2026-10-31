import 'account_session.dart';

/// Stable, provider-neutral categories returned by the backend boundary.
enum BackendAuthenticationFailureCode {
  invalidAuthentication,
  rateLimited,
  providerRejected,
  unavailable,
  invalidSession,
  retryable,
}

/// Transient assertion material produced by a provider adapter.
///
/// This object must never be persisted as application session state.
final class ProviderAuthenticationAssertion {
  const ProviderAuthenticationAssertion({
    required this.provider,
    required this.assertion,
  });

  final AccountProvider provider;
  final String assertion;
}

/// Backend result exposed to the application layer.
///
/// Backend-issued sessions must carry an expiry and use credential rotation on
/// renewal: each successful renewal returns a replacement credential.
/// Only the provider-neutral AccountSession crosses this boundary.
final class BackendAuthenticatedSession {
  const BackendAuthenticatedSession(this.session);

  final AccountSession session;

  DateTime? get expiresAt => session.expiresAt;
  bool get requiresReauthentication => session.requiresReauthentication;
}

/// Transport input for requesting an Email OTP.
final class EmailOtpRequest {
  const EmailOtpRequest({required this.email});

  final String email;
}

/// Transport input for verifying an Email OTP.
///
/// The OTP is transient input and is never copied into AccountSession.
final class EmailOtpVerification {
  const EmailOtpVerification({required this.email, required this.otp});

  final String email;
  final String otp;
}
