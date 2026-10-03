import 'dart:typed_data';

final class MediaAssetDescriptor {
  const MediaAssetDescriptor({
    required this.wordId,
    required this.assetPath,
    required this.license,
    required this.sourceUrl,
    required this.sha256,
    required this.bytes,
  });

  final String wordId;
  final String assetPath;
  final String license;
  final String sourceUrl;
  final String sha256;
  final int bytes;
}

abstract interface class MediaLoaderService {
  Future<Uint8List?> loadWordImage(String wordId);
  Future<MediaAssetDescriptor?> descriptorFor(String wordId);
  void clearMemoryCache();
}
