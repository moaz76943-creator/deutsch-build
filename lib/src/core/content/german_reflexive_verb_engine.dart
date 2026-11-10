/// Case required by the reflexive pronoun.
enum ReflexiveCase { akkusativ, dativ }

/// Nature of the reflexive behavior.
enum ReflexiveCategory { echtReflexiv, unechtReflexiv, reziprok }

/// Grammatical subject pronoun.
enum SubjectPronoun { ich, du, er, sie, es, wir, ihr, siePlural, sieFormal }

/// Represents an analyzed reflexive verb structure.
class ReflexiveVerbAnalysis {
  final String verbInfinitive;
  final SubjectPronoun subject;
  final ReflexiveCase pronounCase;
  final String reflexivePronoun;
  final ReflexiveCategory category;
  final String generatedSentence;

  ReflexiveVerbAnalysis({
    required this.verbInfinitive,
    required this.subject,
    required this.pronounCase,
    required this.reflexivePronoun,
    required this.category,
    required this.generatedSentence,
  });

  Map<String, dynamic> toJson() => {
        'verb': verbInfinitive,
        'subject': subject.name,
        'case': pronounCase.name,
        'pronoun': reflexivePronoun,
        'category': category.name,
        'sentence': generatedSentence,
      };
}

/// Offline rule engine resolving German reflexive and reciprocal verbs.
/// Distinguishes between Akkusativ (mich/dich) and Dativ (mir/dir) reflexives,
/// and handles reciprocal mutual relations (einander / sich gegenseitig).
class GermanReflexiveVerbEngine {
  static const Map<SubjectPronoun, String> _reflexiveAkkusativ = {
    SubjectPronoun.ich: 'mich',
    SubjectPronoun.du: 'dich',
    SubjectPronoun.er: 'sich',
    SubjectPronoun.sie: 'sich',
    SubjectPronoun.es: 'sich',
    SubjectPronoun.wir: 'uns',
    SubjectPronoun.ihr: 'euch',
    SubjectPronoun.siePlural: 'sich',
    SubjectPronoun.sieFormal: 'sich',
  };

  static const Map<SubjectPronoun, String> _reflexiveDativ = {
    SubjectPronoun.ich: 'mir',
    SubjectPronoun.du: 'dir',
    SubjectPronoun.er: 'sich',
    SubjectPronoun.sie: 'sich',
    SubjectPronoun.es: 'sich',
    SubjectPronoun.wir: 'uns',
    SubjectPronoun.ihr: 'euch',
    SubjectPronoun.siePlural: 'sich',
    SubjectPronoun.sieFormal: 'sich',
  };

  static const Map<SubjectPronoun, String> _subjectPronounLabels = {
    SubjectPronoun.ich: 'Ich',
    SubjectPronoun.du: 'Du',
    SubjectPronoun.er: 'Er',
    SubjectPronoun.sie: 'Sie',
    SubjectPronoun.es: 'Es',
    SubjectPronoun.wir: 'Wir',
    SubjectPronoun.ihr: 'Ihr',
    SubjectPronoun.siePlural: 'Sie',
    SubjectPronoun.sieFormal: 'Sie',
  };

  /// Build and inflect a reflexive verb structure.
  /// If a direct accusative object is present (e.g. "die Hände", "die Jacke"),
  /// the reflexive pronoun shifts from Akkusativ to Dativ.
  static ReflexiveVerbAnalysis buildReflexivePhrase({
    required String verbInfinitive,
    required SubjectPronoun subject,
    String? directAccusativeObject,
    ReflexiveCategory category = ReflexiveCategory.unechtReflexiv,
    String conjugatedVerbStem = '',
  }) {
    // When a direct accusative object is explicitly specified, reflexive pronoun is Dativ
    final hasDirectAccObject = directAccusativeObject != null && directAccusativeObject.trim().isNotEmpty;
    final pronounCase = hasDirectAccObject ? ReflexiveCase.dativ : ReflexiveCase.akkusativ;

    final pronoun = (pronounCase == ReflexiveCase.dativ)
        ? _reflexiveDativ[subject]!
        : _reflexiveAkkusativ[subject]!;

    final subjStr = _subjectPronounLabels[subject]!;
    final verbStr = conjugatedVerbStem.isNotEmpty ? conjugatedVerbStem : verbInfinitive;
    final objStr = hasDirectAccObject ? ' $directAccusativeObject' : '';

    final sentence = '$subjStr $verbStr $pronoun$objStr.';

    return ReflexiveVerbAnalysis(
      verbInfinitive: verbInfinitive,
      subject: subject,
      pronounCase: pronounCase,
      reflexivePronoun: pronoun,
      category: category,
      generatedSentence: sentence,
    );
  }
}
