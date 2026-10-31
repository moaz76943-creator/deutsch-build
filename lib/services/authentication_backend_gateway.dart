import '../models/account_session.dart';
import '../models/backend_authentication_contract.dart';
import '../models/backend_transport.dart';
import '../models/secure_session_credentials.dart';
import 'authentication_contract.dart';
import 'authentication_failures.dart';
import 'backend_transport.dart';
import 'secure_session_storage.dart';

final class TransportBackendAuthenticationGateway
    implements BackendAuthenticationGateway {
  TransportBackendAuthenticationGateway(
    this.transport, {
    SecureSessionStorage? secureSessionStorage,
  }) : _secureSessionStorage =
            secureSessionStorage ?? const UnavailableSecureSessionStorage();

  final BackendTransport transport;
  final SecureSessionStorage _secureSessionStorage;
  int _credentialOperationGeneration = 0;
  Future<void> _credentialMutationQueue = Future<void>.value();

  @override
  Future<void> requestEmailOtp(EmailOtpRequest request) async {
    await _send(BackendTransportRequest.requestEmailOtp(email: request.email));
  }

  @override
  Future<AccountSession> verifyEmailOtp(EmailOtpVerification request) async {
    final operationGeneration = ++_credentialOperationGeneration;
    final response = await _send(
      BackendTransportRequest.verifyEmailOtp(
        email: request.email,
        otp: request.otp,
      ),
    );
    final session = _sessionFromResponse(response);
    if (operationGeneration != _credentialOperationGeneration) {
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidSession,
      );
    }
    await _storeCredential(response.credentials, operationGeneration);
    return session;
  }

  @override
  Future<AccountSession> authenticateProvider(
    ProviderAuthenticationAssertion assertion,
  ) async {
    final operationGeneration = ++_credentialOperationGeneration;
    final response = await _send(
      BackendTransportRequest.authenticateProvider(assertion: assertion),
    );
    final session = _sessionFromResponse(response);
    if (operationGeneration != _credentialOperationGeneration) {
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidSession,
      );
    }
    await _storeCredential(response.credentials, operationGeneration);
    return session;
  }

  @override
  Future<AccountSession> renewSession(
    SecureSessionCredentials credentials,
  ) async {
    final operationGeneration = ++_credentialOperationGeneration;
    try {
      final response = await _send(
        BackendTransportRequest.renewSession(credentials: credentials),
      );
      final session = _sessionFromResponse(response);
      if (response.credentials == null) {
        if (operationGeneration == _credentialOperationGeneration) {
          await _clearCredential(operationGeneration);
        }
        throw const AuthenticationFailure(
          AuthenticationFailureCode.invalidSession,
        );
      }
      if (operationGeneration != _credentialOperationGeneration) {
        throw const AuthenticationFailure(
          AuthenticationFailureCode.invalidSession,
        );
      }
      await _storeCredential(response.credentials, operationGeneration);
      return session;
    } on AuthenticationFailure catch (error) {
      if (error.code == AuthenticationFailureCode.invalidSession &&
          operationGeneration == _credentialOperationGeneration) {
        await _clearCredential(operationGeneration);
      }
      rethrow;
    } catch (_) {
      await _clearCredential(operationGeneration);
      rethrow;
    }
  }

  @override
  Future<void> revokeSession(SecureSessionCredentials? credentials) async {
    final operationGeneration = ++_credentialOperationGeneration;
    try {
      await _send(
        BackendTransportRequest.revokeSession(credentials: credentials),
      );
    } finally {
      if (operationGeneration == _credentialOperationGeneration) {
        await _clearCredential(operationGeneration);
      }
    }
  }

  @override
  Future<AccountSession> getCurrentSession() async {
    final operationGeneration = ++_credentialOperationGeneration;
    try {
      final credential = await _secureSessionStorage.read();
      if (credential == null) {
        return const AccountSession.unauthenticated();
      }
      final response = await _send(
        BackendTransportRequest.currentSession(credentials: credential),
      );
      if (operationGeneration != _credentialOperationGeneration) {
        throw const AuthenticationFailure(
          AuthenticationFailureCode.invalidSession,
        );
      }
      final session = _sessionFromResponse(response);
      if (!session.isAuthenticated || session.identity == null) {
        if (operationGeneration == _credentialOperationGeneration) {
          await _clearCredential(operationGeneration);
        }
        throw const AuthenticationFailure(
          AuthenticationFailureCode.invalidSession,
        );
      }
      return session;
    } on AuthenticationFailure catch (error) {
      if (error.code == AuthenticationFailureCode.invalidSession) {
        if (operationGeneration == _credentialOperationGeneration) {
          await _clearCredential(operationGeneration);
        }
      }
      rethrow;
    } on SecureSessionStorageFailure catch (_) {
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidSession,
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _send(const BackendTransportRequest.signOut());
  }

  Future<BackendTransportResponse> _send(
    BackendTransportRequest request,
  ) async {
    try {
      return await transport.send(request);
    } on BackendTransportFailure catch (error) {
      throw _mapFailure(error.code);
    }
  }

  Future<void> _storeCredential(
    SecureSessionCredentials? credentials,
    int operationGeneration,
  ) async {
    if (credentials == null) {
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidSession,
      );
    }
    final applied = await _withCredentialMutationLock(
      operationGeneration,
      () => _secureSessionStorage.save(credentials),
    );
    if (!applied) {
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidSession,
      );
    }
  }

  Future<void> _clearCredential(int operationGeneration) async {
    await _withCredentialMutationLock(
      operationGeneration,
      _secureSessionStorage.clear,
    );
  }

  Future<bool> _withCredentialMutationLock(
    int operationGeneration,
    Future<void> Function() mutation,
  ) async {
    final previous = _credentialMutationQueue;
    final current = previous.then((_) async {
      if (operationGeneration != _credentialOperationGeneration) return false;
      await mutation();
      return true;
    });
    _credentialMutationQueue = current.then<void>((_) {}).catchError((_) {});
    return current;
  }

  static AccountSession _sessionFromResponse(
    BackendTransportResponse response,
  ) {
    final session = response.session;
    if (session == null ||
        !session.isAuthenticated ||
        session.identity == null ||
        session.identity!.userId.trim().isEmpty ||
        session.requiresReauthentication) {
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidSession,
      );
    }
    return session;
  }

  static AuthenticationFailure _mapFailure(BackendTransportFailureCode code) {
    return AuthenticationFailure(switch (code) {
      BackendTransportFailureCode.invalidAuthentication =>
        AuthenticationFailureCode.invalidCredential,
      BackendTransportFailureCode.rateLimited =>
        AuthenticationFailureCode.rateLimited,
      BackendTransportFailureCode.providerRejected =>
        AuthenticationFailureCode.providerRejected,
      BackendTransportFailureCode.unavailable =>
        AuthenticationFailureCode.unavailable,
      BackendTransportFailureCode.invalidSession =>
        AuthenticationFailureCode.invalidSession,
      BackendTransportFailureCode.retryable =>
        AuthenticationFailureCode.retryable,
    });
  }
}

final class UnavailableBackendAuthenticationGateway
    implements BackendAuthenticationGateway {
  const UnavailableBackendAuthenticationGateway();

  @override
  Future<void> requestEmailOtp(EmailOtpRequest request) async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }

  @override
  Future<AccountSession> verifyEmailOtp(EmailOtpVerification request) async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }

  @override
  Future<AccountSession> authenticateProvider(
    ProviderAuthenticationAssertion assertion,
  ) async {
    throw const AuthenticationFailure(AuthenticationFailureCode.unavailable);
  }

  @override
  Future<AccountSession> renewSession(
    SecureSessionCredentials credentials,
  ) async {
    return const AccountSession.unauthenticated();
  }

  @override
  Future<void> revokeSession(SecureSessionCredentials? credentials) async {}

  @override
  Future<AccountSession> getCurrentSession() async {
    return const AccountSession.unauthenticated();
  }

  @override
  Future<void> signOut() async {}
}
