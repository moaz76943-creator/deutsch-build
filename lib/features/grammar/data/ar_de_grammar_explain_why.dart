import '../../../core/explain_why/deterministic_explain_why_engine.dart';
import '../../../core/l10n/l10n_dictionary_codec.dart';

typedef ExplainWhyTextAssetReader = Future<String> Function(String assetPath);

abstract final class ArDeGrammarExplainWhyCatalog {
  static const String assetPath = 'assets/l10n/explain_why/ar.json';

  static ExplainWhyEngine? _cachedEngine;

  static ExplainWhyEngine decode(String encoded) {
    final dictionary = L10nDictionaryCodec.decodeJson(
      encoded,
      localeTag: 'ar',
    );
    return DeterministicExplainWhyEngine.fromDictionary(
      dictionary: dictionary,
      userLanguageCode: 'ar',
      sourceLanguageCode: 'ar',
      targetLanguageCode: 'de',
    );
  }

  static Future<ExplainWhyEngine> load({
    required ExplainWhyTextAssetReader readText,
  }) async {
    final cached = _cachedEngine;
    if (cached != null) return cached;

    final loaded = decode(await readText(assetPath));
    _cachedEngine = loaded;
    return loaded;
  }
}
