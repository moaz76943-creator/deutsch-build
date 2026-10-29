enum ConstituentType {
  nominativeNoun,
  nominativePronoun,
  dativeNoun,
  dativePronoun,
  accusativeNoun,
  accusativePronoun,
  prepositionalPhrase,
  negationNicht,
  adverbial,
}

class MittelfeldConstituent {
  final String text;
  final ConstituentType type;
  final bool isDefinite;

  const MittelfeldConstituent(this.text, this.type, {this.isDefinite = true});
}

class MittelfeldResult {
  final bool isValid;
  final List<String> warnings;
  final List<String> errors;

  const MittelfeldResult({
    required this.isValid,
    required this.warnings,
    required this.errors,
  });
}

/// Offline syntax engine validating canonical German Mittelfeld constituents.
class MittelfeldOrderEngine {
  MittelfeldResult validate(List<MittelfeldConstituent> constituents) {
    final errors = <String>[];
    final warnings = <String>[];

    int? akkPronounIndex;
    int? datPronounIndex;
    int? datNounIndex;
    int? akkNounIndex;

    for (int i = 0; i < constituents.length; i++) {
      final c = constituents[i];
      if (c.type == ConstituentType.accusativePronoun) akkPronounIndex = i;
      if (c.type == ConstituentType.dativePronoun) datPronounIndex = i;
      if (c.type == ConstituentType.dativeNoun) datNounIndex = i;
      if (c.type == ConstituentType.accusativeNoun) akkNounIndex = i;
    }

    // القاعدة الصارمة 1: ترتيب الضمائر (ضمير الأكوزاتيف يسبق ضمير الداتيف حتماً: es ihm)
    if (akkPronounIndex != null && datPronounIndex != null) {
      if (datPronounIndex < akkPronounIndex) {
        errors.add(
          'Grammar Inversion: Dative pronoun "${constituents[datPronounIndex].text}" placed before Accusative pronoun "${constituents[akkPronounIndex].text}". Canonical order: Akk-Pronomen before Dat-Pronomen (z.B. "Ich gebe es ihm").',
        );
      }
    }

    // القاعدة التداولية 2: ترتيب الأسماء (اسم الداتيف يسبق اسم الأكوزاتيف في الترتيب غير الموسوم: dem Mann das Buch)
    if (datNounIndex != null && akkNounIndex != null) {
      if (akkNounIndex < datNounIndex) {
        warnings.add(
          'Stylistic Scrambling: Accusative noun "${constituents[akkNounIndex].text}" placed before Dative noun "${constituents[datNounIndex].text}". Canonical unmarked order is Dativ before Akkusativ.',
        );
      }
    }

    return MittelfeldResult(
      isValid: errors.isEmpty,
      warnings: warnings,
      errors: errors,
    );
  }
}
