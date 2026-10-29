enum OperationType { local, network, download, telemetry }

class DownloadCapability {
  final bool isAuthorized;
  const DownloadCapability._(this.isAuthorized);
}

class OfflineGate {
  static const bool strictOfflineEnforced = true;

  static bool isNetworkRequestPermitted([OperationType type = OperationType.network, DownloadCapability? capability]) {
    if (type == OperationType.telemetry) return false;
    if (type == OperationType.local) return true;

    // For specific download operations, we strictly require a valid, authorized capability
    if (type == OperationType.download) {
      if (strictOfflineEnforced && (capability == null || !capability.isAuthorized)) {
        return false;
      }
      return true;
    }

    // For general network operations, we deny access if strict mode is enforced
    if (type == OperationType.network) {
      return !strictOfflineEnforced;
    }

    return !strictOfflineEnforced;
  }

  static void assertZeroNetworkPolicy([OperationType type = OperationType.network, DownloadCapability? capability]) {
    if (!isNetworkRequestPermitted(type, capability)) {
      throw StateError('Unrestricted network access denied');
    }
  }

  static DownloadCapability authorizeUserDownload(bool explicitConsent) {
    return DownloadCapability._(explicitConsent);
  }

  static bool isTelemetryAllowed() => false;
}
