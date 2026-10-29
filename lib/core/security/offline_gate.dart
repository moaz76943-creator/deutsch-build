class DownloadCapability {
  final String resourceId;
  final DateTime expiresAt;

  DownloadCapability({
    required this.resourceId,
    required this.expiresAt,
  });
}

class DownloadAuthorization {
  final DateTime expiresAt;
  final String signature;

  DownloadAuthorization({
    required this.expiresAt,
    required this.signature,
  });

  bool isAuthorized() {
    if (DateTime.now().isAfter(expiresAt)) return false;
    return signature == 'valid_signature_123';
  }
}

enum OperationType {
  telemetry,
  unrestrictedNetwork,
  localRead,
  localWrite,
  userRequestedDownload,
}

enum NetworkOperation {
  download,
  telemetry,
  general,
}

class OfflineGate {
  static const bool strictOfflineEnforced = true;

  static bool isNetworkRequestPermitted([dynamic operation, dynamic auth]) {
    if (operation == null) {
       return !strictOfflineEnforced;
    }

    if (operation == NetworkOperation.telemetry || operation == NetworkOperation.general) {
      return false;
    }

    if (operation == NetworkOperation.download) {
      if (auth is DownloadAuthorization) {
        return auth.isAuthorized();
      }
      return false;
    }

    return !strictOfflineEnforced;
  }

  static void assertZeroNetworkPolicy([dynamic operation, dynamic auth]) {
    if (operation == null) {
      if (strictOfflineEnforced) {
        throw StateError('Unrestricted network access denied');
      }
      return;
    }

    if (!isNetworkRequestPermitted(operation, auth)) {
      throw Exception('Network operation denied');
    }
  }

  static bool authorizeUserDownload(bool explicitConsent) {
    return explicitConsent;
  }

  static bool isTelemetryAllowed() => false;

  static bool isOperationPermitted(OperationType type, {DownloadCapability? capability}) {
    switch (type) {
      case OperationType.telemetry:
      case OperationType.unrestrictedNetwork:
        return false;
      case OperationType.localRead:
      case OperationType.localWrite:
        return true;
      case OperationType.userRequestedDownload:
        if (capability == null) return false;
        return DateTime.now().isBefore(capability.expiresAt);
    }
  }

  static void assertOperationPolicy(OperationType type, {DownloadCapability? capability}) {
    if (!isOperationPermitted(type, capability: capability)) {
      throw StateError('Operation $type denied');
    }
  }
}
