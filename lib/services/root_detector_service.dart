import 'package:flutter/services.dart';

/// Root and debugger detection service.
///
/// Call isCompromised() before unlocking premium packs, sensitive offline content,
/// or making protected backend requests. Fail-open design prioritizes usability.
class RootDetectorService {
  static const _channel = MethodChannel('com.deutschbilarabi.app/root_detector');

  /// Returns true if the device shows signs of rooting, Magisk, or an attached debugger.
  static Future<bool> isCompromised() async {
    try {
      final result = await _channel.invokeMethod<bool>('isRootedOrCompromised');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isDebuggerAttached() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDebuggerAttached');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
