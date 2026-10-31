import 'package:deutsch_bilarabi/core/explain_why/deterministic_explain_why_engine.dart';
import 'package:deutsch_bilarabi/core/explainer/explainer_models.dart';
import 'package:deutsch_bilarabi/core/l10n/l10n.dart';

Future<void> main() async {
  final arabic = L10nDictionaryCodec.decodeJson(
    '{"locale":"ar","strings":{"chrome.home":"الرئيسية"}}',
  );
  final english = L10nDictionaryCodec.decodeJson(
    '{"locale":"en","strings":{"chrome.help":"Help"}}',
  );
  final engine = DynamicL10nEngine(
    initialState: LocalizationState.fromLanguageTags(
      userLanguageTag: 'ar',
      sourceLanguageTag: 'ar',
      targetLanguageTag: 'de',
    ),
    fallbackLanguageTag: 'en',
    dictionaries: <L10nDictionary>[arabic, english],
  );

  final resolved = engine.resolveUi('chrome.help');
  _expect(engine.uiText('chrome.home'), 'الرئيسية', 'exact UI lookup');
  _expect(resolved.value, 'Help', 'UI fallback value');
  _expect(resolved.requestedLocale, 'ar', 'UI requested locale');
  _expect(resolved.resolvedLocale, 'en', 'UI resolved locale');
  _expect(resolved.usedFallback, true, 'UI fallback marker');
  await engine.close();

  final dictionary = L10nDictionaryCodec.decodeJson(
    '{"locale":"ar","strings":{'
    '"explain.case.correct":"صحيح: {word}",'
    '"explain.case.incorrect":"راجع: {word}"'
    '}}',
  );
  final explainWhy = DeterministicExplainWhyEngine.fromDictionary(
    dictionary: dictionary,
  );
  final result = explainWhy.explain(
    ExplainerRequest(
      reasonCode: 'case',
      correct: true,
      arguments: const <String, String>{'word': 'den Mann'},
    ),
  );

  _expect(result.languageCode, 'ar', 'learning content exact locale');
  _expect(result.text, 'صحيح: den Mann', 'learning content exact render');
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}
