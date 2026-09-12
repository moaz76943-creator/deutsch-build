/// Authentication failures are deliberately explicit and never fabricate an
/// authenticated session.
enum AuthenticationFailureCode {
  cancelled,
  invalidCredential,
  expiredCredential,
  unavailable,
  invalidSession,
  rateLimited,
  providerRejected,
  retryable,
}

final class AuthenticationFailure implements Exception {
  const AuthenticationFailure(this.code);

  final AuthenticationFailureCode code;

  @override
  String toString() => 'AuthenticationFailure($code)';
}
