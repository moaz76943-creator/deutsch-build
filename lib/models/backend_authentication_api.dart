import 'account_session.dart';
import 'backend_authentication_contract.dart';
import 'secure_session_credentials.dart';

/// Semantic authentication operations exposed by the backend API contract.
enum BackendAuthenticationOperation {
  requestEmailOtp,
  verifyEmailOtp,
  authenticateProvider,
  currentSession,
  renewSession,
  revokeSession,
  signOut,
}

/// Transient request for the authentication API. It contains no session or
/// entitlement state and is never intended for persistence.
final class BackendAuthenticationApiRequest {
  const BackendAuthenticationApiRequest({
    required this.operation,
    this.email,
    this.otp,
    this.assertion,
    this.credentials,
  });

  const BackendAuthenticationApiRequest.requestEmailOtp({required String email})
      : this(
          operation: BackendAuthenticationOperation.requestEmailOtp,
          email: email,
        );

  const BackendAuthenticationApiRequest.verifyEmailOtp({
    required String email,
    required String otp,
  }) : this(
          operation: BackendAuthenticationOperation.verifyEmailOtp,
          email: email,
          otp: otp,
        );

  const BackendAuthenticationApiRequest.authenticateProvider({
    required ProviderAuthenticationAssertion assertion,
  }) : this(
          operation: BackendAuthenticationOperation.authenticateProvider,
          assertion: assertion,
        );

  const BackendAuthenticationApiRequest.currentSession({
    SecureSessionCredentials? credentials,
  }) : this(
          operation: BackendAuthenticationOperation.currentSession,
          credentials: credentials,
        );

  const BackendAuthenticationApiRequest.renewSession({
    required SecureSessionCredentials credentials,
  }) : this(
          operation: BackendAuthenticationOperation.renewSession,
          credentials: credentials,
        );

  const BackendAuthenticationApiRequest.revokeSession({
    SecureSessionCredentials? credentials,
  }) : this(
          operation: BackendAuthenticationOperation.revokeSession,
          credentials: credentials,
        );

  const BackendAuthenticationApiRequest.signOut()
      : this(operation: BackendAuthenticationOperation.signOut);

  final BackendAuthenticationOperation operation;
  final String? email;
  final String? otp;
  final ProviderAuthenticationAssertion? assertion;
  final SecureSessionCredentials? credentials;
}

/// Semantic authentication response. A session is present only when the API
/// operation produces one; callers must still validate authentication state.
final class BackendAuthenticationApiResponse {
  const BackendAuthenticationApiResponse({this.session, this.credentials});

  final AccountSession? session;
  final SecureSessionCredentials? credentials;
}
