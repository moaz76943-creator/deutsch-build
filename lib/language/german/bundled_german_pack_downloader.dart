import 'dart:io';

import 'package:flutter/services.dart';

import '../../services/pack_manager_service.dart';

/// Copies the signed German archive from Flutter assets.
/// PackManagerService verifies SHA-256 and encrypts the SQLite database.
final class BundledGermanPackDownloader implements PackDownloader {
  const BundledGermanPackDownloader();

  static const String _asset =
      'assets/content/packs/de/bundles/de-1.0.0.pack.gz';

  static const String _source =
      'https://github.com/sali97m-cpu/deutsch-bilarabi/'
      'releases/download/de-pack-canary-v1/de-1.0.0.pack.gz';

  @override
  Future<int> download(
    Uri source,
    File destination, {
    required int expectedBytes,
    required ValueChanged<double> onProgress,
  }) async {
    if (source.toString() != _source) {
      throw const PackIntegrityException(
        'Unexpected bundled German pack source.',
      );
    }

    final asset = await rootBundle.load(_asset);

    if (asset.lengthInBytes != expectedBytes) {
      throw const PackIntegrityException(
        'Bundled German pack size mismatch.',
      );
    }

    final bytes = asset.buffer.asUint8List(
      asset.offsetInBytes,
      asset.lengthInBytes,
    );

    await destination.parent.create(recursive: true);
    await destination.writeAsBytes(bytes, flush: true);

    onProgress(1.0);
    return asset.lengthInBytes;
  }
}
