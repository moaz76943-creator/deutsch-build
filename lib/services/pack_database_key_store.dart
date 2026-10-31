import 'dart:convert';

import 'package:flutter/services.dart';

abstract interface class PackDatabaseKeyStore {
  Future<String> getOrCreateKey();
  Future<String?> readKey();
}

final class UnavailablePackDatabaseKeyStore implements PackDatabaseKeyStore {
  const UnavailablePackDatabaseKeyStore();

  @override
  Future<String> getOrCreateKey() {
    throw const PackDatabaseKeyStoreException('pack_key_store_unavailable');
  }

  @override
  Future<String?> readKey() async => null;
}

final class AndroidKeystorePackDatabaseKeyStore
    implements PackDatabaseKeyStore {
  AndroidKeystorePackDatabaseKeyStore({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName =
      'com.deutschbilarabi.app/pack_database_key_store';
  static const String _getOrCreateMethod = 'getOrCreate';
  static const String _readMethod = 'read';

  final MethodChannel _channel;

  @override
  Future<String> getOrCreateKey() async {
    final value = await _invoke<String>(_getOrCreateMethod);
    return _validate(value, required: true)!;
  }

  @override
  Future<String?> readKey() async {
    final value = await _invoke<String?>(_readMethod);
    return _validate(value, required: false);
  }

  Future<T?> _invoke<T>(String method) async {
    try {
      return await _channel.invokeMethod<T>(method);
    } on PlatformException catch (error) {
      throw PackDatabaseKeyStoreException('pack_key_store_' + error.code);
    } on MissingPluginException {
      throw const PackDatabaseKeyStoreException('pack_key_store_unavailable');
    }
  }

  String? _validate(String? encoded, {required bool required}) {
    if (encoded == null || encoded.isEmpty) {
      if (!required) return null;
      throw const PackDatabaseKeyStoreException('pack_key_missing');
    }
    try {
      final bytes = base64Decode(encoded);
      if (bytes.length != 32) {
        throw const FormatException();
      }
      return encoded;
    } on Object {
      throw const PackDatabaseKeyStoreException('pack_key_corrupted');
    }
  }
}

final class PackDatabaseKeyStoreException implements Exception {
  const PackDatabaseKeyStoreException(this.code);

  final String code;

  @override
  String toString() => 'PackDatabaseKeyStoreException(' + code + ')';
}
