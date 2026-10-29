enum RelativePronounCase {
  nominative,
  accusative,
  dative,
  genitive,
}

enum RelativeAntecedentGender {
  masculine,
  feminine,
  neuter,
  plural,
}

enum RelativeClauseFocus {
  prepositional,
  genitivePossession,
}

extension RelativePronounCaseLabel on RelativePronounCase {
  String get germanLabel => switch (this) {
        RelativePronounCase.nominative => 'Nominativ',
        RelativePronounCase.accusative => 'Akkusativ',
        RelativePronounCase.dative => 'Dativ',
        RelativePronounCase.genitive => 'Genitiv',
      };

  String get arabicLabel => switch (this) {
        RelativePronounCase.nominative => 'الرفع',
        RelativePronounCase.accusative => 'النصب',
        RelativePronounCase.dative => 'الداتيف',
        RelativePronounCase.genitive => 'الملكية / الجينيتيف',
      };
}

extension RelativeAntecedentGenderPronoun on RelativeAntecedentGender {
  String pronounFor(RelativePronounCase grammaticalCase) => switch (
        (this, grammaticalCase)
      ) {
        (RelativeAntecedentGender.masculine, RelativePronounCase.nominative) =>
          'der',
        (RelativeAntecedentGender.masculine, RelativePronounCase.accusative) =>
          'den',
        (RelativeAntecedentGender.masculine, RelativePronounCase.dative) =>
          'dem',
        (RelativeAntecedentGender.masculine, RelativePronounCase.genitive) =>
          'dessen',
        (RelativeAntecedentGender.feminine, RelativePronounCase.nominative) =>
          'die',
        (RelativeAntecedentGender.feminine, RelativePronounCase.accusative) =>
          'die',
        (RelativeAntecedentGender.feminine, RelativePronounCase.dative) =>
          'der',
        (RelativeAntecedentGender.feminine, RelativePronounCase.genitive) =>
          'deren',
        (RelativeAntecedentGender.neuter, RelativePronounCase.nominative) =>
          'das',
        (RelativeAntecedentGender.neuter, RelativePronounCase.accusative) =>
          'das',
        (RelativeAntecedentGender.neuter, RelativePronounCase.dative) =>
          'dem',
        (RelativeAntecedentGender.neuter, RelativePronounCase.genitive) =>
          'dessen',
        (RelativeAntecedentGender.plural, RelativePronounCase.nominative) =>
          'die',
        (RelativeAntecedentGender.plural, RelativePronounCase.accusative) =>
          'die',
        (RelativeAntecedentGender.plural, RelativePronounCase.dative) =>
          'denen',
        (RelativeAntecedentGender.plural, RelativePronounCase.genitive) =>
          'deren',
      };

  String get arabicLabel => switch (this) {
        RelativeAntecedentGender.masculine => 'مذكر',
        RelativeAntecedentGender.feminine => 'مؤنث',
        RelativeAntecedentGender.neuter => 'محايد',
        RelativeAntecedentGender.plural => 'جمع',
      };
}

extension RelativeClauseFocusLabel on RelativeClauseFocus {
  String get arabicLabel => switch (this) {
        RelativeClauseFocus.prepositional => 'حرف جر + ضمير نسبي',
        RelativeClauseFocus.genitivePossession => 'Genitiv: dessen / deren',
      };
}

final class RelativeClauseChallengeItem {
  RelativeClauseChallengeItem({
    required this.id,
    required this.antecedent,
    required this.antecedentGender,
    required this.sourceSentence,
    required this.relativeIdea,
    required this.correctSentence,
    required this.grammaticalCase,
    required this.focus,
    required this.arabicExplanation,
    this.preposition,
  }) {
    if (id.trim().isEmpty ||
        antecedent.trim().isEmpty ||
        sourceSentence.trim().isEmpty ||
        relativeIdea.trim().isEmpty ||
        correctSentence.trim().isEmpty ||
        arabicExplanation.trim().isEmpty) {
      throw ArgumentError('Invalid relative clause challenge.');
    }
    if (focus == RelativeClauseFocus.prepositional &&
        (preposition == null || preposition!.trim().isEmpty)) {
      throw ArgumentError(
        'Prepositional relative clause requires a preposition.',
      );
    }
    if (focus == RelativeClauseFocus.genitivePossession &&
        grammaticalCase != RelativePronounCase.genitive) {
      throw ArgumentError(
        'Genitive possession requires the genitive relative form.',
      );
    }
  }

  final String id;
  final String antecedent;
  final RelativeAntecedentGender antecedentGender;
  final String sourceSentence;
  final String relativeIdea;
  final String correctSentence;
  final RelativePronounCase grammaticalCase;
  final RelativeClauseFocus focus;
  final String arabicExplanation;
  final String? preposition;

  String get expectedPronoun =>
      antecedentGender.pronounFor(grammaticalCase);
}
