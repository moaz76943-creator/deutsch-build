enum NetworkOperationType {
  general,
  telemetry,
  userDirectedDownload,
}

class OfflineGate {
  static const bool strictOfflineEnforced = true;

  static bool isNetworkRequestPermitted(NetworkOperationType type, {String? authorizationToken}) {
    if (!strictOfflineEnforced) return true;

    switch (type) {
      case NetworkOperationType.general:
      case NetworkOperationType.telemetry:
        return false;
      case NetworkOperationType.userDirectedDownload:
        return authorizationToken != null && _isValidToken(authorizationToken);
    }
  }

  static void assertZeroNetworkPolicy(NetworkOperationType type, {String? authorizationToken}) {
    if (!isNetworkRequestPermitted(type, authorizationToken: authorizationToken)) {
      throw Exception('Network operation of type $type is blocked by zero-network policy.');
    }
  }

  static bool _isValidToken(String token) {
    // For now, basic mock validation
    // Avoid inventing new private signing keys, this is an explicit ephemeral/user-directed authorization
    // In a real app this would verify a signature or session token.
    return token.startsWith('user_auth_');
  }
}
