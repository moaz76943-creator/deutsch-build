import 'package:flutter/foundation.dart';

import '../models/account_session.dart';
import 'authentication.dart';

/// Application-facing session state.
///
/// This controller owns only transient authentication state. It never reads
/// or mutates learner data and never persists credentials.
final class AuthSessionController extends ChangeNotifier {
  AuthSessionController(this._authenticationService);

  final AuthenticationService _authenticationService;
  AccountSession _session = const AccountSession.unauthenticated();
  bool _isInitialized = false;
  AuthenticationFailure? _lastFailure;
  int _operationGeneration = 0;

  AccountSession get session => _session;
  bool get isInitialized => _isInitialized;
  AuthenticationFailure? get lastFailure => _lastFailure;

  Future<void> initialize() async {
    final operationGeneration = ++_operationGeneration;
    try {
      final session = await _authenticationService.currentSession;
      if (operationGeneration != _operationGeneration) return;
      _setSession(session);
      _lastFailure = null;
    } on AuthenticationFailure catch (error) {
      if (operationGeneration != _operationGeneration) return;
      _setFailure(error);
      _setSession(const AccountSession.unauthenticated());
    } catch (_) {
      if (operationGeneration != _operationGeneration) return;
      _setFailure(
        const AuthenticationFailure(AuthenticationFailureCode.unavailable),
      );
      _setSession(const AccountSession.unauthenticated());
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> requestEmailOtp({required String email}) async {
    final operationGeneration = ++_operationGeneration;
    try {
      await _authenticationService.requestEmailOtp(email: email);
      if (operationGeneration != _operationGeneration) return;
      _lastFailure = null;
    } on AuthenticationFailure catch (error) {
      if (operationGeneration != _operationGeneration) return;
      _setFailure(error);
    } catch (_) {
      if (operationGeneration != _operationGeneration) return;
      _setFailure(
        const AuthenticationFailure(AuthenticationFailureCode.unavailable),
      );
    }
    if (operationGeneration == _operationGeneration) notifyListeners();
  }

  Future<void> signInWithEmailOtp({
    required String email,
    required String otp,
  }) async {
    await _runAuthentication(() {
      return _authenticationService.signInWithEmailOtp(email: email, otp: otp);
    });
  }

  Future<void> signInWithGoogle() async {
    await _runAuthentication(_authenticationService.signInWithGoogle);
  }

  Future<void> signInWithApple() async {
    await _runAuthentication(_authenticationService.signInWithApple);
  }

  Future<void> renewSession() async {
    final operationGeneration = ++_operationGeneration;
    try {
      final session = await _authenticationService.renewSession();
      if (operationGeneration != _operationGeneration) return;
      _setSession(session);
      _lastFailure = null;
    } on AuthenticationFailure catch (error) {
      if (operationGeneration != _operationGeneration) return;
      _setFailure(error);
      _setSession(const AccountSession.unauthenticated());
    } catch (_) {
      if (operationGeneration != _operationGeneration) return;
      _setFailure(
        const AuthenticationFailure(AuthenticationFailureCode.unavailable),
      );
      _setSession(const AccountSession.unauthenticated());
    }
    if (operationGeneration == _operationGeneration) notifyListeners();
  }

  Future<void> signOut() async {
    final operationGeneration = ++_operationGeneration;
    try {
      await _authenticationService.signOut();
      if (operationGeneration != _operationGeneration) return;
      _setSession(const AccountSession.unauthenticated());
      _lastFailure = null;
    } on AuthenticationFailure catch (error) {
      if (operationGeneration != _operationGeneration) return;
      _setFailure(error);
      _setSession(const AccountSession.unauthenticated());
    } catch (_) {
      if (operationGeneration != _operationGeneration) return;
      _setFailure(
        const AuthenticationFailure(AuthenticationFailureCode.unavailable),
      );
      _setSession(const AccountSession.unauthenticated());
    }
    if (operationGeneration == _operationGeneration) notifyListeners();
  }

  Future<void> _runAuthentication(
    Future<AccountSession> Function() operation,
  ) async {
    final operationGeneration = ++_operationGeneration;
    try {
      final session = await operation();
      if (operationGeneration != _operationGeneration) return;
      _setSession(session);
      _lastFailure = null;
    } on AuthenticationFailure catch (error) {
      if (operationGeneration != _operationGeneration) return;
      _setFailure(error);
      _setSession(const AccountSession.unauthenticated());
    } catch (_) {
      if (operationGeneration != _operationGeneration) return;
      _setFailure(
        const AuthenticationFailure(AuthenticationFailureCode.unavailable),
      );
      _setSession(const AccountSession.unauthenticated());
    }
    if (operationGeneration == _operationGeneration) notifyListeners();
  }

  void _setSession(AccountSession session) {
    _session = session.isAuthenticated &&
            session.identity != null &&
            !session.requiresReauthentication
        ? session
        : const AccountSession.unauthenticated();
  }

  void _setFailure(AuthenticationFailure failure) {
    _lastFailure = failure;
  }
}
