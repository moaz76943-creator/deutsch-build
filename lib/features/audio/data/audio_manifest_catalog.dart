import 'dart:convert';

import '../domain/entities/audio_request.dart';
import '../domain/services/audio_catalog.dart';

final class AudioManifestCatalog implements AudioCatalog {
  AudioManifestCatalog._({
    required this.baseAssetPath,
    required Map<String, Map<AudioVariant, String>> entries,
  }) : _entries = entries;

  factory AudioManifestCatalog.empty({
    String baseAssetPath = 'content/german/audio',
  }) =>
      AudioManifestCatalog._(
        baseAssetPath: baseAssetPath,
        entries: const <String, Map<AudioVariant, String>>{},
      );

  factory AudioManifestCatalog.parse(
    String rawJson, {
    String baseAssetPath = 'content/german/audio',
  }) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic> ||
        decoded['version'] != 1 ||
        decoded['entries'] is! List) {
      throw const FormatException('audio_manifest_invalid');
    }

    final result = <String, Map<AudioVariant, String>>{};
    for (final rawEntry in decoded['entries'] as List<dynamic>) {
      if (rawEntry is! Map) {
        throw const FormatException('audio_manifest_entry_invalid');
      }
      final entry = Map<String, dynamic>.from(rawEntry);
      final id = _requiredToken(entry['contentId']);
      if (result.containsKey(id)) {
        throw const FormatException('audio_manifest_duplicate_content_id');
      }

      final variants = <AudioVariant, String>{};
      _addVariant(variants, AudioVariant.word, entry['word']);
      _addVariant(variants, AudioVariant.sentence, entry['sentence']);
      _addVariant(variants, AudioVariant.pronunciation, entry['pronunciation']);
      result[id] = Map<AudioVariant, String>.unmodifiable(variants);
    }

    return AudioManifestCatalog._(
      baseAssetPath: _safeBase(baseAssetPath),
      entries: Map<String, Map<AudioVariant, String>>.unmodifiable(result),
    );
  }

  final String baseAssetPath;
  final Map<String, Map<AudioVariant, String>> _entries;

  @override
  String? recordedAssetFor({
    required String conceptId,
    required AudioVariant variant,
  }) {
    final variants = _entries[conceptId];
    if (variants == null) return null;
    final relative = variants[variant] ??
        (variant == AudioVariant.pronunciation
            ? variants[AudioVariant.word]
            : null);
    if (relative == null) return null;
    return baseAssetPath + '/' + relative;
  }

  static void _addVariant(
    Map<AudioVariant, String> variants,
    AudioVariant variant,
    Object? raw,
  ) {
    if (raw == null) return;
    final value = _safeRelativeAudioPath(raw);
    variants[variant] = value;
  }

  static String _requiredToken(Object? raw) {
    if (raw is! String) {
      throw const FormatException('audio_manifest_content_id_invalid');
    }
    final value = raw.trim();
    if (value.isEmpty || value.length > 160) {
      throw const FormatException('audio_manifest_content_id_invalid');
    }
    return value;
  }

  static String _safeBase(String raw) {
    final value = raw.trim().replaceAll('\\', '/');
    if (value.isEmpty ||
        value.startsWith('/') ||
        value.contains('../') ||
        value.contains('/..') ||
        value.contains('//')) {
      throw const FormatException('audio_manifest_base_path_invalid');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static String _safeRelativeAudioPath(Object? raw) {
    if (raw is! String) {
      throw const FormatException('audio_manifest_path_invalid');
    }
    final value = raw.trim().replaceAll('\\', '/');
    if (value.isEmpty ||
        value.startsWith('/') ||
        value.contains('../') ||
        value.contains('/..') ||
        value.contains('//')) {
      throw const FormatException('audio_manifest_path_invalid');
    }
    final lower = value.toLowerCase();
    const allowed = <String>{'.aac', '.flac', '.m4a', '.mp3', '.ogg', '.wav'};
    if (!allowed.any(lower.endsWith)) {
      throw const FormatException('audio_manifest_extension_invalid');
    }
    return value;
  }
}
