enum VerbKind { regular, irregular, separable }

enum VerbTense {
  praesens('Präsens'),
  praeteritum('Präteritum'),
  perfekt('Perfekt');

  const VerbTense(this.label);
  final String label;
}

enum PerfectAuxiliary {
  haben('haben'),
  sein('sein');

  const PerfectAuxiliary(this.infinitive);
  final String infinitive;
}

enum GermanPronoun {
  ich('ich'),
  du('du'),
  erSieEs('er/sie/es'),
  wir('wir'),
  ihr('ihr'),
  sieSie('sie/Sie');

  const GermanPronoun(this.label);
  final String label;
}

class VerbConjugationTable {
  const VerbConjugationTable({
    required this.tense,
    required this.forms,
    this.auxiliary,
    this.participle,
  });

  final VerbTense tense;
  final Map<GermanPronoun, String> forms;
  final PerfectAuxiliary? auxiliary;
  final String? participle;

  String formFor(GermanPronoun pronoun) => forms[pronoun] ?? '';
}

class VerbItem {
  const VerbItem({
    required this.infinitive,
    required this.meaningAr,
    required this.kind,
    required this.tables,
    this.presentEmphasisTokens = const <String>[],
  });

  final String infinitive;
  final String meaningAr;
  final VerbKind kind;
  final Map<VerbTense, VerbConjugationTable> tables;
  final List<String> presentEmphasisTokens;

  VerbConjugationTable tableFor(VerbTense tense) {
    final table = tables[tense];
    if (table == null) {
      throw StateError('$infinitive is missing ${tense.label}');
    }
    return table;
  }
}

class VerbLexemeSpec {
  const VerbLexemeSpec({
    required this.infinitive,
    required this.meaningAr,
    required this.kind,
    required this.presentForms,
    required this.preteriteForms,
    required this.auxiliary,
    required this.participle,
    this.presentEmphasisTokens = const <String>[],
  });

  final String infinitive;
  final String meaningAr;
  final VerbKind kind;
  final Map<GermanPronoun, String> presentForms;
  final Map<GermanPronoun, String> preteriteForms;
  final PerfectAuxiliary auxiliary;
  final String participle;
  final List<String> presentEmphasisTokens;
}

class VerbTextSegment {
  const VerbTextSegment(this.text, {required this.emphasized});

  final String text;
  final bool emphasized;
}
