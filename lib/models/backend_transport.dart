import 'account_session.dart';
import 'backend_authentication_contract.dart';
import 'secure_session_credentials.dart';

/// Provider-neutral operations that may cross the backend transport boundary.
enum BackendTransportOperation {
  requestEmailOtp,
  verifyEmailOtp,
  authenticateProvider,
  currentSession,
  renewSession,
  revokeSession,
  signOut,
}

/// Transport-safe request envelope. Payloads remain transient and are not
/// application session state.
final class BackendTransportRequest {
  const BackendTransportRequest({
    required this.operation,
    this.email,
    this.otp,
    this.assertion,
    this.credentials,
  });

  const BackendTransportRequest.requestEmailOtp({required String email})
      : this(
            operation: BackendTransportOperation.requestEmailOtp, email: email);

  const BackendTransportRequest.verifyEmailOtp({
    required String email,
    required String otp,
  }) : this(
          operation: BackendTransportOperation.verifyEmailOtp,
          email: email,
          otp: otp,
        );

  const BackendTransportRequest.authenticateProvider({
    required ProviderAuthenticationAssertion assertion,
  }) : this(
          operation: BackendTransportOperation.authenticateProvider,
          assertion: assertion,
        );

  const BackendTransportRequest.currentSession({
    SecureSessionCredentials? credentials,
  }) : this(
          operation: BackendTransportOperation.currentSession,
          credentials: credentials,
        );

  const BackendTransportRequest.renewSession({
    required SecureSessionCredentials credentials,
  }) : this(
          operation: BackendTransportOperation.renewSession,
          credentials: credentials,
        );

  const BackendTransportRequest.revokeSession({
    SecureSessionCredentials? credentials,
  }) : this(
          operation: BackendTransportOperation.revokeSession,
          credentials: credentials,
        );

  const BackendTransportRequest.signOut()
      : this(operation: BackendTransportOperation.signOut);

  final BackendTransportOperation operation;
  final String? email;
  final String? otp;
  final ProviderAuthenticationAssertion? assertion;
  final SecureSessionCredentials? credentials;
}

/// Provider-neutral response. Authentication responses expose only the
/// already-canonical AccountSession.
final class BackendTransportResponse {
  const BackendTransportResponse({this.session, this.credentials});

  final AccountSession? session;
  final SecureSessionCredentials? credentials;
}

/// Stable transport-level failure categories.
enum BackendTransportFailureCode {
  invalidAuthentication,
  rateLimited,
  providerRejected,
  unavailable,
  invalidSession,
  retryable,
}
