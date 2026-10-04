import 'polyglot_language_pack.dart';

typedef LanguagePackTextLoader = Future<String> Function(String path);

final class LanguagePackRepository {
  LanguagePackRepository({
    required LanguagePackTextLoader loadText,
    this.assetRoot = 'assets/lang_data',
  }) : _loadText = loadText;

  final LanguagePackTextLoader _loadText;
  final String assetRoot;

  PolyglotLanguagePackCatalog? _catalog;
  PolyglotLanguagePack? _activePack;

  String? get activePair => _activePack?.directedPair;
  PolyglotLanguagePack? get activePack => _activePack;
  PolyglotLanguagePackCatalog? get catalog => _catalog;

  Future<PolyglotLanguagePackCatalog> loadCatalog() async {
    final current = _catalog;
    if (current != null) return current;

    final encoded = await _loadText(_pathFor('catalog.json'));
    final loaded = PolyglotLanguagePackCatalog.parse(encoded);
    _catalog = loaded;
    return loaded;
  }

  Future<PolyglotLanguagePack> loadPair(
    String sourceLanguage,
    String targetLanguage,
  ) async {
    final source = _language(sourceLanguage, 'sourceLanguage');
    final target = _language(targetLanguage, 'targetLanguage');
    if (source == target) {
      throw ArgumentError(
        'Source and target language must be different.',
      );
    }

    final pair = '$source->$target';
    final active = _activePack;
    if (active != null && active.directedPair == pair) {
      return active;
    }

    final catalog = await loadCatalog();
    final entry = catalog.requirePair(source, target);
    if (!entry.isLoadable) {
      throw StateError(
        'Language pack $pair is not loadable: '
        '${entry.reason ?? entry.readiness}.',
      );
    }

    final encoded = await _loadText(
      _pathFor(fileNameForPair(source, target)),
    );
    final loaded = PolyglotLanguagePack.parse(encoded);
    if (loaded.directedPair != pair) {
      throw FormatException(
        'Loaded pack pair ${loaded.directedPair} does not match $pair.',
      );
    }
    if (entry.checksum != loaded.checksum) {
      throw FormatException(
        'Catalog checksum does not match loaded pack $pair.',
      );
    }

    _activePack = loaded;
    return loaded;
  }

  void clear() {
    _activePack = null;
  }

  void clearAll() {
    _activePack = null;
    _catalog = null;
  }

  String _pathFor(String fileName) {
    final root = assetRoot.trim();
    if (root.isEmpty) return fileName;

    final normalizedRoot = root.endsWith('/')
        ? root.substring(0, root.length - 1)
        : root;
    return '$normalizedRoot/$fileName';
  }

  static String fileNameForPair(
    String sourceLanguage,
    String targetLanguage,
  ) {
    final source = _language(sourceLanguage, 'sourceLanguage');
    final target = _language(targetLanguage, 'targetLanguage');
    return '${source.replaceAll('-', '_')}_'
        '${target.replaceAll('-', '_')}.json';
  }
}

String _language(String value, String field) {
  final normalized = value.trim().replaceAll('_', '-').toLowerCase();
  if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$')
      .hasMatch(normalized)) {
    throw ArgumentError.value(
      value,
      field,
      'must be a valid language tag',
    );
  }
  return normalized;
}
