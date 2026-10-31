enum GermanArticle {
  der,
  die,
  das;

  String get label => name;
}

enum GermanCase {
  nominative,
  accusative,
  dative,
  genitive,
  notApplicable;

  String get labelDe => switch (this) {
        GermanCase.nominative => 'Nominativ',
        GermanCase.accusative => 'Akkusativ',
        GermanCase.dative => 'Dativ',
        GermanCase.genitive => 'Genitiv',
        GermanCase.notApplicable => '—',
      };
}

enum SentenceWordOrderPattern {
  svo,
  subordinateVerbFinal,
  modalBracket,
  custom;

  String get labelDe => switch (this) {
        SentenceWordOrderPattern.svo => 'SVO / V2',
        SentenceWordOrderPattern.subordinateVerbFinal =>
          'Nebensatz · Verb am Ende',
        SentenceWordOrderPattern.modalBracket =>
          'Modalverb · Satzklammer',
        SentenceWordOrderPattern.custom => 'Satzbau',
      };

  String get explanationAr => switch (this) {
        SentenceWordOrderPattern.svo =>
          'في الجملة الرئيسية يأتي الفعل المصرف غالبًا في الموقع الثاني، مع ترتيب واضح للفاعل وبقية الجملة.',
        SentenceWordOrderPattern.subordinateVerbFinal =>
          'في الجملة الفرعية مثل weil أو dass ينتقل الفعل المصرف عادةً إلى نهاية الجملة.',
        SentenceWordOrderPattern.modalBracket =>
          'الفعل الناقص يكون مصرفًا في الموقع الثاني، بينما يأتي المصدر في نهاية الجملة ليكوّنا قوس الجملة.',
        SentenceWordOrderPattern.custom =>
          'راجع أجزاء الجملة أدناه لفهم موقع كل عنصر وعلاقته ببقية الجملة.',
      };
}

final class VerbConjugation {
  const VerbConjugation({
    required this.present,
    required this.preterite,
    required this.perfect,
    this.prepositions = const <String>[],
    this.isModal = false,
  });

  final String present;
  final String preterite;
  final String perfect;
  final List<String> prepositions;
  final bool isModal;
}

final class NounGrammar {
  const NounGrammar({
    required this.article,
    required this.plural,
    required this.grammaticalCase,
  });

  final GermanArticle article;
  final String plural;
  final GermanCase grammaticalCase;
}

final class SentenceLexeme {
  const SentenceLexeme({
    required this.lemma,
    this.forms = const <String>{},
    this.phoneticAliases = const <String>{},
    this.verb,
    this.noun,
    this.syntaxRoleDe,
    this.syntaxRoleAr,
  }) : assert(verb == null || noun == null);

  final String lemma;
  final Set<String> forms;
  final Set<String> phoneticAliases;
  final VerbConjugation? verb;
  final NounGrammar? noun;
  final String? syntaxRoleDe;
  final String? syntaxRoleAr;

  bool get isVerb => verb != null;
  bool get isNoun => noun != null;
}

final class SyntaxSegment {
  const SyntaxSegment({
    required this.labelDe,
    required this.labelAr,
    required this.text,
  });

  final String labelDe;
  final String labelAr;
  final String text;
}

final class SentenceEntry {
  const SentenceEntry({
    required this.id,
    required this.german,
    required this.translationAr,
    this.lexicon = const <SentenceLexeme>[],
    this.syntaxBreakdown = const <SyntaxSegment>[],
    this.phoneticAliases = const <String>[],
    this.wordOrderPattern = SentenceWordOrderPattern.custom,
  });

  final String id;
  final String german;
  final String translationAr;
  final List<SentenceLexeme> lexicon;
  final List<SyntaxSegment> syntaxBreakdown;
  final List<String> phoneticAliases;
  final SentenceWordOrderPattern wordOrderPattern;
}

final class SentenceToken {
  const SentenceToken({
    required this.index,
    required this.text,
    required this.normalized,
    required this.isPunctuation,
    this.lexeme,
  });

  final int index;
  final String text;
  final String normalized;
  final bool isPunctuation;
  final SentenceLexeme? lexeme;

  VerbConjugation? get verb => lexeme?.verb;
  NounGrammar? get noun => lexeme?.noun;
  bool get isInspectable => !isPunctuation;
}

final class SentenceSearchHit {
  const SentenceSearchHit({
    required this.sentence,
    required this.score,
  });

  final SentenceEntry sentence;
  final double score;
}
