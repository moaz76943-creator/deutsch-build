/// Part of speech resulting from the derivation process.
enum DerivedPartOfSpeech { noun, adjective, verb }

/// Morphological derivation process type.
enum DerivationProcessType { prefixation, suffixation, conversion }

/// Descriptor of a decomposed or derived word.
class MorphologicalDerivationResult {
  final String surfaceWord;
  final String rootStem;
  final String affix;
  final DerivationProcessType process;
  final DerivedPartOfSpeech resultingCategory;
  final String genderIfNoun; // der, die, das, or empty
  final String semanticFunction;
  final String arabicExplanation;

  MorphologicalDerivationResult({
    required this.surfaceWord,
    required this.rootStem,
    required this.affix,
    required this.process,
    required this.resultingCategory,
    this.genderIfNoun = '',
    required this.semanticFunction,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'word': surfaceWord,
        'root': rootStem,
        'affix': affix,
        'process': process.name,
        'category': resultingCategory.name,
        'gender': genderIfNoun,
        'function': semanticFunction,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine analyzing German derivational morphology (Wortbildungsmuster).
/// Decomposes complex nouns, adjectives, and prefixed verbs to reveal morphological stems.
class GermanDerivationalMorphologyEngine {
  static const Map<String, String> _nounSuffixGenders = {
    'ung': 'die',
    'heit': 'die',
    'keit': 'die',
    'schaft': 'die',
    'tät': 'die',
    'taet': 'die',
    'ion': 'die',
    'tum': 'das',
    'ling': 'der',
    'nis': 'das',
  };

  static const Map<String, String> _inseparablePrefixFunctions = {
    'be': 'تحويل الفعل إلى متعدٍّ لمفعول به مباشر (Transitivierung)',
    'ent': 'تفيد الإزالة، الفصل، أو البداية (Entfernung / Beginn)',
    'er': 'تفيد الوصول إلى نتيجة أو تحقيق الهدف (Zielerreichung)',
    'ver': 'تفيد التغيير، الخطأ، أو إنهاء الفعل (Veränderung / Fehler)',
    'zer': 'تفيد التفكيك، التحطيم، والتفتيت (Zerstörung / Auflösung)',
    'miss': 'تفيد الخطأ أو المعنى السلبي المعاكس (Misserfolg / Fehler)',
  };

  /// Analyze a complex derived German word.
  static MorphologicalDerivationResult analyzeWord(String word) {
    final clean = word.trim().toLowerCase();

    // 1. Check noun derivational suffixes
    for (final entry in _nounSuffixGenders.entries) {
      if (clean.endsWith(entry.key) && clean.length > entry.key.length + 2) {
        final stem = clean.substring(0, clean.length - entry.key.length);
        final cap = word[0].toUpperCase() + word.substring(1);
        return MorphologicalDerivationResult(
          surfaceWord: cap,
          rootStem: stem,
          affix: '-${entry.key}',
          process: DerivationProcessType.suffixation,
          resultingCategory: DerivedPartOfSpeech.noun,
          genderIfNoun: entry.value,
          semanticFunction: 'اشتقاق اسم مجرد أو دال على الحدث والصفة',
          arabicExplanation: 'اللاحقة (-${entry.key}) تشتق دائماً اسماً أداته (${entry.value})',
        );
      }
    }

    // 2. Check adjective derivational suffixes (-bar, -lich, -ig, -los, -voll)
    final adjSuffixes = {'bar': 'إمكانية الفعل', 'lich': 'صفة كيفية أو دورية', 'los': 'نفي وانعدام الشيء', 'voll': 'الامتلاء والوفرة', 'ig': 'خاصية مستمرة'};
    for (final entry in adjSuffixes.entries) {
      if (clean.endsWith(entry.key) && clean.length > entry.key.length + 2) {
        final stem = clean.substring(0, clean.length - entry.key.length);
        return MorphologicalDerivationResult(
          surfaceWord: clean,
          rootStem: stem,
          affix: '-${entry.key}',
          process: DerivationProcessType.suffixation,
          resultingCategory: DerivedPartOfSpeech.adjective,
          semanticFunction: entry.value,
          arabicExplanation: 'اللاحقة (-${entry.key}) تشتق صفة تدل على: ${entry.value}',
        );
      }
    }

    // 3. Check inseparable verbal prefixes (be-, ent-, er-, ver-, zer-, miss-)
    for (final entry in _inseparablePrefixFunctions.entries) {
      if (clean.startsWith(entry.key) && clean.length > entry.key.length + 3 && clean.endsWith('en')) {
        final stem = clean.substring(entry.key.length);
        return MorphologicalDerivationResult(
          surfaceWord: clean,
          rootStem: stem,
          affix: '${entry.key}-',
          process: DerivationProcessType.prefixation,
          resultingCategory: DerivedPartOfSpeech.verb,
          semanticFunction: entry.value,
          arabicExplanation: 'السابقة (${entry.key}-) تعدل معنى الفعل الأصلي: ${entry.value}',
        );
      }
    }

    // Fallback: root word
    return MorphologicalDerivationResult(
      surfaceWord: word,
      rootStem: clean,
      affix: '',
      process: DerivationProcessType.conversion,
      resultingCategory: DerivedPartOfSpeech.noun,
      semanticFunction: 'جذر لغوي أصيل',
      arabicExplanation: 'الكلمة تمثل جذراً معجمياً أساسياً',
    );
  }
}
