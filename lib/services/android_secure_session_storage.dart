import 'package:flutter/services.dart';

import '../models/secure_session_credentials.dart';
import 'secure_session_storage.dart';

/// Android implementation backed by the platform Keystore boundary.
///
/// Only the opaque credential value crosses the platform channel transiently.
/// The Dart layer never handles keys, ciphertext, or storage files.
final class AndroidSecureSessionStorage implements SecureSessionStorage {
  AndroidSecureSessionStorage({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName =
      'com.deutschbilarabi.app/secure_session_storage';
  static const String _saveMethod = 'save';
  static const String _readMethod = 'read';
  static const String _clearMethod = 'clear';

  final MethodChannel _channel;

  @override
  Future<void> save(SecureSessionCredentials credentials) async {
    await _invoke<void>(_saveMethod, <String, Object?>{
      'value': credentials.value,
    });
  }

  @override
  Future<SecureSessionCredentials?> read() async {
    final value = await _invoke<String?>(_readMethod);
    return value == null ? null : SecureSessionCredentials(value);
  }

  @override
  Future<void> clear() async {
    await _invoke<void>(_clearMethod);
  }

  @override
  Future<void> replace(SecureSessionCredentials credentials) =>
      save(credentials);

  Future<T?> _invoke<T>(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (error) {
      throw SecureSessionStorageFailure(_mapFailure(error.code));
    } on MissingPluginException {
      throw const SecureSessionStorageFailure(
        SecureSessionStorageFailureCode.unavailable,
      );
    }
  }

  static SecureSessionStorageFailureCode _mapFailure(String code) {
    switch (code) {
      case 'corrupted':
        return SecureSessionStorageFailureCode.corrupted;
      case 'unreadable':
        return SecureSessionStorageFailureCode.unreadable;
      default:
        return SecureSessionStorageFailureCode.unavailable;
    }
  }
}
