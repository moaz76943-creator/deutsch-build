import '../models/secure_session_credentials.dart';

/// Storage failures are deliberately non-semantic: callers must fail closed
/// rather than inspect or recover credential contents.
enum SecureSessionStorageFailureCode { unavailable, corrupted, unreadable }

final class SecureSessionStorageFailure implements Exception {
  const SecureSessionStorageFailure(this.code);

  final SecureSessionStorageFailureCode code;

  @override
  String toString() => 'SecureSessionStorageFailure($code)';
}

/// Platform-secure storage boundary for authenticated session credentials.
///
/// A future Android implementation must use platform-secure primitives. This
/// contract intentionally selects no package or concrete storage mechanism.
/// Replacement means the new credential is the only credential reported by a
/// successful operation; an implementation must not report success after a
/// failed write.
abstract interface class SecureSessionStorage {
  Future<void> save(SecureSessionCredentials credentials);

  Future<SecureSessionCredentials?> read();

  Future<void> clear();

  Future<void> replace(SecureSessionCredentials credentials) =>
      save(credentials);
}

/// Safe default while no real platform-secure implementation exists.
/// Nothing is persisted.
final class UnavailableSecureSessionStorage implements SecureSessionStorage {
  const UnavailableSecureSessionStorage();

  @override
  Future<void> save(SecureSessionCredentials credentials) async {
    throw const SecureSessionStorageFailure(
      SecureSessionStorageFailureCode.unavailable,
    );
  }

  @override
  Future<SecureSessionCredentials?> read() async => null;

  @override
  Future<void> clear() async {}

  @override
  Future<void> replace(SecureSessionCredentials credentials) async {
    throw const SecureSessionStorageFailure(
      SecureSessionStorageFailureCode.unavailable,
    );
  }
}
