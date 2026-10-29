enum OperationType {
  localRead,
  localWrite,
  userRequestedDownload,
  telemetry,
  unrestrictedNetwork,
}

class DownloadCapability {
  final String resourceId;
  final DateTime expiresAt;

  const DownloadCapability({
    required this.resourceId,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class OfflineGate {
  static const bool strictOfflineEnforced = true;

  static bool isNetworkRequestPermitted() => !strictOfflineEnforced;

  static void assertZeroNetworkPolicy() {
    if (strictOfflineEnforced) {
      // منع تام لأي اتصال خارجي بدون إذن صريح للحفاظ على الخصوصية والسرعة
      throw Exception('Unrestricted network access is denied by zero network policy.');
    }
  }

  static bool isOperationPermitted(
    OperationType type, {
    DownloadCapability? capability,
  }) {
    switch (type) {
      case OperationType.localRead:
      case OperationType.localWrite:
        return true;
      case OperationType.telemetry:
      case OperationType.unrestrictedNetwork:
        return false;
      case OperationType.userRequestedDownload:
        if (capability == null) return false;
        if (capability.isExpired) return false;
        return true;
    }
  }

  static void assertOperationPolicy(
    OperationType type, {
    DownloadCapability? capability,
  }) {
    if (!isOperationPermitted(type, capability: capability)) {
      throw Exception('Operation not permitted by offline policy');
    }
  }
}
