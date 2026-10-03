import '../models/account_session.dart';
import '../models/backend_authentication_contract.dart';
import '../models/secure_session_credentials.dart';
import 'authentication_contract.dart';
import 'authentication_failures.dart';
import 'authentication_backend_gateway.dart';
import 'secure_session_storage.dart';

/// Small orchestration layer that keeps provider adapters independent.
final class ProviderAuthenticationService implements AuthenticationService {
  ProviderAuthenticationService({
    required EmailOtpProvider emailOtpProvider,
    required SocialAuthenticationProvider googleProvider,
    required SocialAuthenticationProvider appleProvider,
    BackendAuthenticationGateway? backendGateway,
    SecureSessionStorage? secureSessionStorage,
  })  : _emailOtpProvider = emailOtpProvider,
        _backendGateway =
            backendGateway ?? const UnavailableBackendAuthenticationGateway(),
        _secureSessionStorage =
            secureSessionStorage ?? const UnavailableSecureSessionStorage(),
        _googleProvider = _requireProvider(
          googleProvider,
          AccountProvider.google,
        ),
        _appleProvider = _requireProvider(appleProvider, AccountProvider.apple);

  final EmailOtpProvider _emailOtpProvider;
  final BackendAuthenticationGateway _backendGateway;
  final SecureSessionStorage _secureSessionStorage;
  final SocialAuthenticationProvider _googleProvider;
  final SocialAuthenticationProvider _appleProvider;
  AccountSession _session = const AccountSession.unauthenticated();
  int _storageOperationGeneration = 0;

  @override
  Future<AccountSession> get currentSession async {
    final operationGeneration = ++_storageOperationGeneration;
    try {
      final session = await _backendGateway.getCurrentSession();
      if (operationGeneration != _storageOperationGeneration) {
        throw const AuthenticationFailure(
          AuthenticationFailureCode.invalidSession,
        );
      }
      _session = _canonicalSession(session);
    } on AuthenticationFailure {
      rethrow;
    } catch (_) {
      if (operationGeneration == _storageOperationGeneration) {
        _session = const AccountSession.unauthenticated();
      }
    }
    if (operationGeneration == _storageOperationGeneration &&
        _session.requiresReauthentication) {
      _session = const AccountSession.unauthenticated();
    }
    if (operationGeneration != _storageOperationGeneration) {
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidSession,
      );
    }
    return _session;
  }

  @override
  Future<void> requestEmailOtp({required String email}) =>
      _emailOtpProvider.requestCode(email: email);

  @override
  Future<AccountSession> signInWithEmailOtp({
    required String email,
    required String otp,
  }) async {
    return _authenticate(
      () => _backendGateway.verifyEmailOtp(
        EmailOtpVerification(email: email, otp: otp),
      ),
    );
  }

  @override
  Future<AccountSession> signInWithGoogle() async {
    return _authenticate(() async {
      final assertion = await _googleProvider.authenticate();
      return _backendGateway.authenticateProvider(assertion);
    });
  }

  @override
  Future<AccountSession> signInWithApple() async {
    return _authenticate(() async {
      final assertion = await _appleProvider.authenticate();
      return _backendGateway.authenticateProvider(assertion);
    });
  }

  @override
  Future<AccountSession> renewSession() async {
    final operationGeneration = ++_storageOperationGeneration;
    SecureSessionCredentials? credentials;
    try {
      credentials = await _secureSessionStorage.read();
    } on SecureSessionStorageFailure catch (_) {
      if (operationGeneration == _storageOperationGeneration) {
        _session = const AccountSession.unauthenticated();
      }
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidSession,
      );
    }
    if (credentials == null) {
      if (operationGeneration == _storageOperationGeneration) {
        _session = const AccountSession.unauthenticated();
      }
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidSession,
      );
    }
    try {
      final renewed = await _backendGateway.renewSession(credentials);
      final canonical = _canonicalSession(renewed);
      if (!canonical.isAuthenticated || canonical.identity == null) {
        if (operationGeneration == _storageOperationGeneration) {
          _session = const AccountSession.unauthenticated();
        }
        throw const AuthenticationFailure(
          AuthenticationFailureCode.invalidSession,
        );
      }
      if (_session.isAuthenticated &&
          _session.identity != null &&
          canonical.identity!.userId != _session.identity!.userId) {
        throw const AuthenticationFailure(
          AuthenticationFailureCode.invalidSession,
        );
      }
      final replacement = await _secureSessionStorage.read();
      if (replacement == null) {
        if (operationGeneration == _storageOperationGeneration) {
          _session = const AccountSession.unauthenticated();
        }
        throw const AuthenticationFailure(
          AuthenticationFailureCode.invalidSession,
        );
      }
      if (operationGeneration != _storageOperationGeneration) {
        throw const AuthenticationFailure(
          AuthenticationFailureCode.invalidSession,
        );
      }
      _session = canonical;
      return canonical;
    } on AuthenticationFailure catch (_) {
      if (operationGeneration == _storageOperationGeneration) {
        _session = const AccountSession.unauthenticated();
      }
      rethrow;
    } catch (_) {
      if (operationGeneration == _storageOperationGeneration) {
        _session = const AccountSession.unauthenticated();
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    final operationGeneration = ++_storageOperationGeneration;
    try {
      SecureSessionCredentials? credentials;
      try {
        credentials = await _secureSessionStorage.read();
      } on SecureSessionStorageFailure {
        credentials = null;
      }
      await _backendGateway.revokeSession(credentials);
    } finally {
      if (operationGeneration == _storageOperationGeneration) {
        _session = const AccountSession.unauthenticated();
      }
    }
  }

  Future<AccountSession> _authenticate(
    Future<AccountSession> Function() operation,
  ) async {
    final operationGeneration = ++_storageOperationGeneration;
    final result = await operation();
    if (operationGeneration != _storageOperationGeneration) {
      throw const AuthenticationFailure(
        AuthenticationFailureCode.invalidSession,
      );
    }
    final canonical = _canonicalSession(result);
    _session = canonical;
    return canonical;
  }

  static AccountSession _canonicalSession(AccountSession result) {
    if (!result.isAuthenticated ||
        result.identity == null ||
        result.identity!.userId.trim().isEmpty ||
        result.requiresReauthentication) {
      return const AccountSession.unauthenticated();
    }
    return result;
  }

  static SocialAuthenticationProvider _requireProvider(
    SocialAuthenticationProvider provider,
    AccountProvider expected,
  ) {
    if (provider.provider != expected) {
      throw ArgumentError.value(
        provider.provider,
        'provider',
        'Expected $expected adapter.',
      );
    }
    return provider;
  }
}
