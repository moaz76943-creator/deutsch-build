import 'l10n_dictionary_codec.dart';
import 'l10n_models.dart';

typedef L10nTextAssetReader = Future<String> Function(String assetPath);

final class L10nBundleLoader {
  L10nBundleLoader({
    required L10nTextAssetReader readText,
  }) : _readText = readText;

  final L10nTextAssetReader _readText;

  Future<L10nDictionary> load({
    required String assetPath,
    required L10nSourceFormat format,
    String? localeTag,
  }) async {
    final normalizedPath = assetPath.trim();
    if (normalizedPath.isEmpty) {
      throw ArgumentError.value(
        assetPath,
        'assetPath',
        'must not be empty',
      );
    }

    final encoded = await _readText(normalizedPath);
    if (encoded.trim().isEmpty) {
      throw FormatException(
        'Localization asset "$normalizedPath" is empty.',
      );
    }

    return switch (format) {
      L10nSourceFormat.json => L10nDictionaryCodec.decodeJson(
          encoded,
          localeTag: localeTag,
        ),
      L10nSourceFormat.arb => L10nDictionaryCodec.decodeArb(
          encoded,
          localeTag: localeTag,
        ),
    };
  }

  Future<List<L10nDictionary>> loadAll(
    Iterable<L10nBundleRequest> requests,
  ) async {
    final result = <L10nDictionary>[];
    final seenPaths = <String>{};

    for (final request in requests) {
      final path = request.assetPath.trim();
      if (!seenPaths.add(path)) {
        throw ArgumentError(
          'Duplicate localization asset path: $path.',
        );
      }
      result.add(
        await load(
          assetPath: path,
          format: request.format,
          localeTag: request.localeTag,
        ),
      );
    }

    return List<L10nDictionary>.unmodifiable(result);
  }
}

final class L10nBundleRequest {
  L10nBundleRequest({
    required String assetPath,
    required this.format,
    this.localeTag,
  }) : assetPath = assetPath.trim() {
    if (this.assetPath.isEmpty) {
      throw ArgumentError.value(
        assetPath,
        'assetPath',
        'must not be empty',
      );
    }
  }

  final String assetPath;
  final L10nSourceFormat format;
  final String? localeTag;
}
