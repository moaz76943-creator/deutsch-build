import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

final class ContentValidationCache {
  ContentValidationCache._({
    required this.file,
    required this.validatorVersion,
    required Map<String, String> entries,
  }) : _entries = entries;

  final File file;
  final String validatorVersion;
  final Map<String, String> _entries;

  static Future<ContentValidationCache> open({
    required String path,
    required String validatorVersion,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return ContentValidationCache._(
        file: file,
        validatorVersion: validatorVersion,
        entries: <String, String>{},
      );
    }

    try {
      final bytes = await file.readAsBytes();
      final decoded = utf8.decode(bytes, allowMalformed: false);
      final raw = jsonDecode(decoded);
      if (raw is! Map) {
        throw const FormatException('validation cache must be an object');
      }
      final version = raw['validatorVersion'];
      final entryValue = raw['entries'];
      if (version != validatorVersion || entryValue is! Map) {
        return ContentValidationCache._(
          file: file,
          validatorVersion: validatorVersion,
          entries: <String, String>{},
        );
      }

      final entries = <String, String>{};
      for (final entry in entryValue.entries) {
        if (entry.key is String && entry.value is String) {
          entries[entry.key as String] = entry.value as String;
        }
      }
      return ContentValidationCache._(
        file: file,
        validatorVersion: validatorVersion,
        entries: entries,
      );
    } on Object {
      return ContentValidationCache._(
        file: file,
        validatorVersion: validatorVersion,
        entries: <String, String>{},
      );
    }
  }

  bool isValidated({
    required String key,
    required String checksum,
  }) =>
      _entries[key] == checksum;

  void remember({
    required String key,
    required String checksum,
  }) {
    _entries[key] = checksum;
  }

  int get entryCount => _entries.length;

  Future<void> persist() async {
    await file.parent.create(recursive: true);
    final sorted = _entries.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    final payload = <String, Object?>{
      'validatorVersion': validatorVersion,
      'entries': <String, String>{
        for (final entry in sorted) entry.key: entry.value,
      },
    };
    final encoded = utf8.encode(jsonEncode(payload));
    final temp = File(file.path + '.tmp');
    await temp.writeAsBytes(encoded, flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await temp.rename(file.path);
  }
}

abstract final class ValidationFingerprint {
  static final Sha256 _sha256 = Sha256();

  static Future<String> bytes(List<int> bytes) async {
    final digest = await _sha256.hash(bytes);
    final buffer = StringBuffer();
    for (final byte in digest.bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  static Future<String> jsonValue(Object? value) =>
      bytes(utf8.encode(jsonEncode(value)));
}
