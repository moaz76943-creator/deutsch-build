enum LinguisticPartOfSpeech {
  noun,
  verb,
  adjective,
  adverb,
  pronoun,
  preposition,
  conjunction,
  particle,
  numeral,
  interjection,
  phrase,
  other,
  unknown;

  String get wireName => name;

  static LinguisticPartOfSpeech fromWire(String? value) {
    final normalized = value?.trim().toLowerCase();
    return LinguisticPartOfSpeech.values.firstWhere(
      (item) => item.wireName == normalized,
      orElse: () => LinguisticPartOfSpeech.unknown,
    );
  }
}

enum LanguageRegister {
  neutral,
  formal,
  informal,
  colloquial,
  written,
  academic,
  unknown;

  String get wireName => name;

  static LanguageRegister fromWire(String? value) {
    final normalized = value?.trim().toLowerCase();
    return LanguageRegister.values.firstWhere(
      (item) => item.wireName == normalized,
      orElse: () => LanguageRegister.unknown,
    );
  }
}

enum CefrLevel {
  unknown,
  a1,
  a2,
  b1,
  b2,
  c1,
  c2;

  String get wireName =>
      this == CefrLevel.unknown ? 'unknown' : name.toUpperCase();

  static CefrLevel fromWire(String? value) {
    final normalized = value?.trim().toUpperCase();
    return CefrLevel.values.firstWhere(
      (item) => item.wireName == normalized,
      orElse: () => CefrLevel.unknown,
    );
  }
}

/// Language-neutral identity for a single lexical sense.
///
/// German morphology is intentionally stored in dedicated language models so
/// this object can remain usable by future language packs without adopting a
/// German-shaped universal schema.
final class LinguisticConcept {
  const LinguisticConcept({
    required this.id,
    required this.senseId,
    required this.lemma,
    required this.partOfSpeech,
    required this.register,
    required this.cefr,
    this.semanticTags = const <String>[],
  });

  final String id;
  final String senseId;
  final String lemma;
  final LinguisticPartOfSpeech partOfSpeech;
  final LanguageRegister register;
  final CefrLevel cefr;
  final List<String> semanticTags;
}
