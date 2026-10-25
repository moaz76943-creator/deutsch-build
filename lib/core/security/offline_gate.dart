class OfflineGate {
  static const bool strictOfflineEnforced = true;

  static bool isNetworkRequestPermitted() => !strictOfflineEnforced;

  static void assertZeroNetworkPolicy() {
    if (strictOfflineEnforced) {
      throw StateError('Unrestricted network access denied');
    }
  }

  static bool authorizeUserDownload(bool explicitConsent) {
    // Only permit optional user-requested downloads explicitly authorized.
    // Ensure this doesn't enable general unrestricted network access.
    return explicitConsent == true;
  }

  static bool isTelemetryAllowed() => false;
}
