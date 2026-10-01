/// Canonical provider-independent account identity.
final class AccountIdentity {
  const AccountIdentity({required this.userId});

  final String userId;

  @override
  bool operator ==(Object other) {
    return other is AccountIdentity && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

enum AccountProvider { emailOtp, google, apple }

/// Immutable authentication state exposed to the application.
final class AccountSession {
  const AccountSession._({
    required this.isAuthenticated,
    this.identity,
    this.expiresAt,
  });

  const AccountSession.unauthenticated() : this._(isAuthenticated: false);

  const AccountSession.authenticated({
    required AccountIdentity identity,
    DateTime? expiresAt,
  }) : this._(isAuthenticated: true, identity: identity, expiresAt: expiresAt);

  final bool isAuthenticated;
  final AccountIdentity? identity;
  final DateTime? expiresAt;

  bool get requiresReauthentication {
    if (!isAuthenticated || expiresAt == null) {
      return false;
    }
    return !DateTime.now().isBefore(expiresAt!);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountSession &&
        other.isAuthenticated == isAuthenticated &&
        other.identity == identity &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode => Object.hash(isAuthenticated, identity, expiresAt);
}
