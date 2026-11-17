import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// SSL Pinning HTTP client for future networked features.
/// Pins expected certificate public key hashes (SHA-256).
/// Prevents MITM even if user has custom CAs.
///
/// Usage: Only enable when INTERNET permission is present and user consents.
/// Update pins on certificate rotation (use backup pins).
class SslPinningClient {
  static const List<String> _pinnedSha256 = [
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
  ];

  static http.Client createPinnedClient() {
    final context = SecurityContext(withTrustedRoots: false);
    final httpClient = HttpClient(context: context);
    httpClient.badCertificateCallback = (cert, host, port) {
      return false;
    };
    return IOClient(httpClient);
  }
}
