enum VerbPrefixClass { trennbar, untrennbar, doppeldeutig }

enum PrefixContext { travel, technology, literature, engineering }

final class PrefixDrillItem {
  const PrefixDrillItem({
    required this.id,
    required this.infinitive,
    required this.prefix,
    required this.stem,
    required this.verbClass,
    required this.context,
    required this.isSeparableInContext,
    required this.sentencePrompt,
    required this.correctSentence,
    required this.partizipII,
    required this.translationAr,
    required this.explanationAr,
  });

  final String id;
  final String infinitive;
  final String prefix;
  final String stem;
  final VerbPrefixClass verbClass;
  final PrefixContext context;
  final bool isSeparableInContext;
  final String sentencePrompt;
  final String correctSentence;
  final String partizipII;
  final String translationAr;
  final String explanationAr;

  String get classLabelDe => switch (verbClass) {
        VerbPrefixClass.trennbar => 'Trennbar',
        VerbPrefixClass.untrennbar => 'Untrennbar',
        VerbPrefixClass.doppeldeutig => 'Doppeldeutig',
      };

  String get contextLabelAr => switch (context) {
        PrefixContext.travel => 'السفر',
        PrefixContext.technology => 'التكنولوجيا',
        PrefixContext.literature => 'الأدب',
        PrefixContext.engineering => 'الهندسة',
      };

  String get splitLabel =>
      isSeparableInContext ? '$prefix | $stem' : '$prefix$stem';
}
