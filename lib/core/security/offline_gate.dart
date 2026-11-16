class DownloadCapability {
  final int expiresAt;
  final String contentId;

  const DownloadCapability({
    required this.expiresAt,
    required this.contentId,
  });

  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expiresAt;
}

enum OperationType {
  localRead,
  localWrite,
  userRequestedDownload,
  telemetry,
  unrestrictedNetwork,
}

class OfflineGate {
  static const bool strictOfflineEnforced = true;

  static bool isNetworkRequestPermitted() => false;

  static void assertZeroNetworkPolicy() {
    if (strictOfflineEnforced) {
      throw StateError('Unrestricted network access denied');
    }
  }

  static DownloadCapability? authorizeUserDownload(bool explicitConsent, String contentId) {
    if (explicitConsent) {
      return DownloadCapability(
        expiresAt: DateTime.now().millisecondsSinceEpoch + 15 * 60 * 1000, // 15 mins
        contentId: contentId,
      );
    }
    return null;
  }

  static bool isTelemetryAllowed() => false;

  static bool isOperationPermitted(OperationType type, {DownloadCapability? capability}) {
    switch (type) {
      case OperationType.localRead:
      case OperationType.localWrite:
        return true;
      case OperationType.telemetry:
      case OperationType.unrestrictedNetwork:
        return false;
      case OperationType.userRequestedDownload:
        if (capability != null && !capability.isExpired) {
          return true;
        }
        return false;
    }
  }

  static void assertOperationPolicy(OperationType type, {DownloadCapability? capability}) {
    if (!isOperationPermitted(type, capability: capability)) {
      throw StateError('Operation ${type.name} denied by strict offline policy');
    }
  }
}
