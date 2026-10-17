import 'grammar_capabilities.dart';

class GrammarProfile {
  final String languageCode;
  final Set<GrammarCapability> capabilities;

  const GrammarProfile({
    required this.languageCode,
    required this.capabilities,
  });

  bool supports(GrammarCapability capability) => capabilities.contains(capability);
}
