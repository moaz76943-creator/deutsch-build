import 'universal_grammar_provider.dart';

class UniversalGrammarEngine {
  final Map<String, UniversalGrammarProvider> _registry = {};

  void registerProvider(UniversalGrammarProvider provider) {
    _registry[provider.languageCode] = provider;
  }

  UniversalGrammarProvider? getProvider(String languageCode) {
    return _registry[languageCode];
  }

  void clear() {
    _registry.clear();
  }
}
