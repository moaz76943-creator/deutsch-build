class OfflineGate {
  static const bool strictOfflineEnforced = true;

  static bool isNetworkRequestPermitted() => !strictOfflineEnforced;

  static void assertZeroNetworkPolicy() {
    if (strictOfflineEnforced) {
      throw StateError('Unrestricted network access denied');
    }
  }

  static bool authorizeUserDownload(bool explicitConsent) {
    if (explicitConsent && strictOfflineEnforced) {
      return true;
    }
    return false;
  }

  static bool isTelemetryAllowed() => false;
}
