/// Etymological link connecting a target word with a familiar language.
class CognateRelation {
  final String targetWord;
  final String targetLanguage;
  final String bridgeWord;
  final String bridgeLanguage;
  final String ancestralRoot;
  final double phoneticSimilarity;
  final bool isFalseFriend;
  final String mnemonicNote;

  const CognateRelation({
    required this.targetWord,
    required this.targetLanguage,
    required this.bridgeWord,
    required this.bridgeLanguage,
    required this.ancestralRoot,
    required this.phoneticSimilarity,
    required this.isFalseFriend,
    required this.mnemonicNote,
  });
}

/// Maps cross-linguistic lexical transfer to accelerate acquisition.
class EtymologicalCognateBridge {
  static const List<CognateRelation> _knownBridges = [
    CognateRelation(
      targetWord: 'Wasser',
      targetLanguage: 'de',
      bridgeWord: 'Water',
      bridgeLanguage: 'en',
      ancestralRoot: 'Proto-Germanic *watōr',
      phoneticSimilarity: 0.88,
      isFalseFriend: false,
      mnemonicNote: 'Grimm’s law shift: Germanic /t/ became High German /s/ (water -> Wasser).',
    ),
    CognateRelation(
      targetWord: 'Apfel',
      targetLanguage: 'de',
      bridgeWord: 'Apple',
      bridgeLanguage: 'en',
      ancestralRoot: 'Proto-Germanic *aplaz',
      phoneticSimilarity: 0.85,
      isFalseFriend: false,
      mnemonicNote: 'High German consonant shift /p/ -> /pf/.',
    ),
    CognateRelation(
      targetWord: 'bekommen',
      targetLanguage: 'de',
      bridgeWord: 'become',
      bridgeLanguage: 'en',
      ancestralRoot: 'Proto-West-Germanic *bikweman',
      phoneticSimilarity: 0.90,
      isFalseFriend: true,
      mnemonicNote: 'FALSE FRIEND WARNING: German "bekommen" means "to receive/get", NOT "to become" (werden).',
    ),
    CognateRelation(
      targetWord: 'Zucker',
      targetLanguage: 'de',
      bridgeWord: 'سكر (Sukkar)',
      bridgeLanguage: 'ar',
      ancestralRoot: 'Sanskrit śarkarā via Arabic sukkar',
      phoneticSimilarity: 0.82,
      isFalseFriend: false,
      mnemonicNote: 'Loanword transmission through Mediterranean trade routes into Old High German.',
    ),
  ];

  /// Finds cognate bridges for a given word in a target language.
  List<CognateRelation> findBridges(String word, {String? userKnownLanguage}) {
    final lower = word.trim().toLowerCase();
    return _knownBridges.where((rel) {
      final matchesWord = rel.targetWord.toLowerCase() == lower;
      final matchesLang = userKnownLanguage == null || rel.bridgeLanguage == userKnownLanguage;
      return matchesWord && matchesLang;
    }).toList();
  }

  /// Calculates cognitive acquisition discount based on cognate presence.
  double calculateCognitiveDiscount(List<CognateRelation> bridges) {
    if (bridges.isEmpty) return 0.0;
    final top = bridges.first;
    if (top.isFalseFriend) return -0.3; // False friends increase interference
    return (top.phoneticSimilarity * 0.6).clamp(0.0, 0.6);
  }
}
