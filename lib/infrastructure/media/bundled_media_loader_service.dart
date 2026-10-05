import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/media/cache_manager.dart';
import '../../core/media/media_loader_service.dart';

final class BundledMediaLoaderService implements MediaLoaderService {
  BundledMediaLoaderService({
    AssetBundle? bundle,
    CacheManager? cache,
    this.manifestAsset = 'assets/media/assets_manifest.json',
  })  : _bundle = bundle ?? rootBundle,
        _cache = cache ?? CacheManager();

  static const int _maxImageBytes = 30 * 1024;

  final AssetBundle _bundle;
  final CacheManager _cache;
  final String manifestAsset;

  Map<String, MediaAssetDescriptor>? _index;
  Future<Map<String, MediaAssetDescriptor>>? _loadingManifest;

  @override
  Future<Uint8List?> loadWordImage(String wordId) async {
    final normalized = wordId.trim();
    if (normalized.isEmpty) return null;

    final cached = _cache.get(normalized);
    if (cached != null) return cached;

    final index = await _ensureIndex();
    final descriptor = index[normalized];
    if (descriptor == null) return null;

    final data = await _bundle.load(descriptor.assetPath);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    if (bytes.lengthInBytes != descriptor.bytes ||
        bytes.lengthInBytes > _maxImageBytes) {
      throw FormatException('media asset size drift for $normalized');
    }
    _cache.put(normalized, bytes);
    return bytes;
  }

  @override
  Future<MediaAssetDescriptor?> descriptorFor(String wordId) async {
    final normalized = wordId.trim();
    if (normalized.isEmpty) return null;
    final index = await _ensureIndex();
    return index[normalized];
  }

  @override
  void clearMemoryCache() => _cache.clear();

  Future<Map<String, MediaAssetDescriptor>> _ensureIndex() async {
    final loaded = _index;
    if (loaded != null) return loaded;
    final inFlight = _loadingManifest;
    if (inFlight != null) return inFlight;

    final future = _loadManifest();
    _loadingManifest = future;
    try {
      return await future;
    } finally {
      _loadingManifest = null;
    }
  }

  Future<Map<String, MediaAssetDescriptor>> _loadManifest() async {
    final encoded = await _bundle.loadString(manifestAsset);
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('media manifest must be a JSON object');
    }
    if (decoded['schema_version'] != 1 || decoded['max_image_bytes'] != _maxImageBytes) {
      throw const FormatException('unsupported media manifest contract');
    }
    final assets = decoded['assets'];
    if (assets is! List) {
      throw const FormatException('media manifest assets must be a list');
    }

    final index = <String, MediaAssetDescriptor>{};
    for (final raw in assets) {
      if (raw is! Map) {
        throw const FormatException('media manifest entry must be an object');
      }
      final wordId = raw['word_id'];
      final assetPath = raw['asset_path'];
      final license = raw['license'];
      final sourceUrl = raw['source_url'];
      final sha256 = raw['sha256'];
      final bytes = raw['bytes'];
      if (wordId is! String ||
          assetPath is! String ||
          license is! String ||
          sourceUrl is! String ||
          sha256 is! String ||
          bytes is! int) {
        throw const FormatException('media manifest entry has invalid fields');
      }
      if (license != 'CC0' && license != 'PUBLIC DOMAIN') {
        throw FormatException('unsupported media license for $wordId');
      }
      if (bytes <= 0 || bytes > _maxImageBytes) {
        throw FormatException('invalid media byte size for $wordId');
      }
      if (index.containsKey(wordId)) {
        throw FormatException('duplicate media word_id: $wordId');
      }
      index[wordId] = MediaAssetDescriptor(
        wordId: wordId,
        assetPath: assetPath,
        license: license,
        sourceUrl: sourceUrl,
        sha256: sha256,
        bytes: bytes,
      );
    }
    _index = Map<String, MediaAssetDescriptor>.unmodifiable(index);
    return _index!;
  }
}
