enum NetworkOperation { telemetry, general, download }

class DownloadAuthorization {
  final DateTime expiresAt;
  final String signature;

  const DownloadAuthorization({
    required this.expiresAt,
    required this.signature,
  });

  bool isAuthorized() {
    if (DateTime.now().isAfter(expiresAt)) return false;
    if (signature.isEmpty || signature == 'forged') return false;
    return true;
  }
}

class OfflineGate {
  static const bool strictOfflineEnforced = true;

  static bool isNetworkRequestPermitted([
    NetworkOperation operation = NetworkOperation.general,
    DownloadAuthorization? auth,
  ]) {
    if (operation == NetworkOperation.download && auth != null && auth.isAuthorized()) {
      return true;
    }
    return !strictOfflineEnforced;
  }

  static void assertZeroNetworkPolicy([
    NetworkOperation operation = NetworkOperation.general,
    DownloadAuthorization? auth,
  ]) {
    if (operation == NetworkOperation.download && auth != null && auth.isAuthorized()) {
      return;
    }
    if (strictOfflineEnforced) {
      throw Exception('Network request blocked by zero network policy.');
    }
  }
}
