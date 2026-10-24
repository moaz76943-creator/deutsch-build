import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Client-side Play Integrity API wrapper.
///
/// Request a token before sensitive operations (premium packs, backend calls).
/// Always verify the token on your backend with Google's API. Do not trust client-side only.
///
/// Setup required:
/// 1. Link Cloud Project in Play Console > App integrity > Play Integrity API.
/// 2. Set CLOUD_PROJECT_NUMBER in AndroidPlayIntegrityManager.kt.
/// 3. Register the MethodChannel in MainActivity.configureFlutterEngine:
///    MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
///        AndroidPlayIntegrityManager.CHANNEL_NAME)
///        .setMethodCallHandler(AndroidPlayIntegrityManager(this))
///
/// Also enable Automatic Integrity Protection in Play Console when creating a release.
class PlayIntegrityService {
  static const _channel = MethodChannel('com.deutschbilarabi.app/play_integrity');

  /// Requests an integrity token. Provide a nonce from your backend when possible
  /// to bind the token to a specific request.
  static Future<String?> requestIntegrityToken({String? nonce}) async {
    try {
      final token = await _channel.invokeMethod<String>(
        'requestIntegrityToken',
        {'nonce': nonce},
      );
      return token;
    } on PlatformException catch (e) {
      // Log or handle: not_configured, integrity_failed, etc.
      debugPrint('Play Integrity error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Play Integrity unexpected error: $e');
      return null;
    }
  }
}
