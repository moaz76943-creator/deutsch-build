import 'dart:math';

/// Type of phonetic listening exercise.
enum PhoneticExerciseType {
  minimalPairDiscrimination, // schon vs schön, bieten vs bitten
  audioToWordMatching,       // Listen and select correct word
  vowelLengthIdentification, // Short vowel vs long vowel detection
}

/// Item representing a word with precise phonetic annotations.
class PhoneticItem {
  final String id;
  final String word;
  final String ipa;
  final String audioKey; // Key for local offline TTS or cached audio asset
  final String translationAr;
  final List<String> acousticDistractors; // Minimal pair contrasts
  final String phoneticRuleExplanation;

  const PhoneticItem({
    required this.id,
    required this.word,
    required this.ipa,
    required this.audioKey,
    required this.translationAr,
    required this.acousticDistractors,
    required this.phoneticRuleExplanation,
  });
}

/// Generated exercise for listening drills.
class ListeningPhoneticsExercise {
  final String exerciseId;
  final PhoneticExerciseType type;
  final String targetWord;
  final String targetIpa;
  final String audioKey;
  final String questionPrompt;
  final List<String> options;
  final String expectedAnswer;
  final String translationAr;
  final String explanation;

  const ListeningPhoneticsExercise({
    required this.exerciseId,
    required this.type,
    required this.targetWord,
    required this.targetIpa,
    required this.audioKey,
    required this.questionPrompt,
    required this.options,
    required this.expectedAnswer,
    required this.translationAr,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'type': type.name,
    'targetWord': targetWord,
    'targetIpa': targetIpa,
    'audioKey': audioKey,
    'questionPrompt': questionPrompt,
    'options': options,
    'expectedAnswer': expectedAnswer,
    'translationAr': translationAr,
    'explanation': explanation,
  };
}

/// Result of evaluating learner's listening response.
class ListeningValidationResult {
  final bool isCorrect;
  final String expectedAnswer;
  final String submittedAnswer;
  final String feedback;
  final String ipaComparison;

  const ListeningValidationResult({
    required this.isCorrect,
    required this.expectedAnswer,
    required this.submittedAnswer,
    required this.feedback,
    required this.ipaComparison,
  });
}

/// Generator for German listening and phonetics discrimination exercises.
class ListeningPhoneticsExerciseGenerator {
  final Random _random;

  ListeningPhoneticsExerciseGenerator({Random? random})
      : _random = random ?? Random();

  /// Sovereign curated bank of German minimal pairs and phonetic contrast items.
  static const List<PhoneticItem> defaultBank = [
    PhoneticItem(
      id: 'ph_001',
      word: 'bieten',
      ipa: '[ˈbiːtn̩]',
      audioKey: 'audio_bieten_001',
      translationAr: 'يعرض / يقدّم',
      acousticDistractors: ['bitten', 'beten'],
      phoneticRuleExplanation: 'حرف (ie) هنا مصوت طويل ممدود [iː]، بعكس (bitten) حيث حرف (i) قصير ومتبوع بحرف ساكن مضاعف.',
    ),
    PhoneticItem(
      id: 'ph_002',
      word: 'schon',
      ipa: '[ʃoːn]',
      audioKey: 'audio_schon_002',
      translationAr: 'بالفعل / من قبل',
      acousticDistractors: ['schön', 'Sohn'],
      phoneticRuleExplanation: 'حرف (o) بدون أوملاوت [oː] يختلف كلياً عن (ö) في schön [ʃøːn] التي تتطلب تدوير الشفاه.',
    ),
    PhoneticItem(
      id: 'ph_003',
      word: 'Beet',
      ipa: '[beːt]',
      audioKey: 'audio_beet_003',
      translationAr: 'حوض زراعي',
      acousticDistractors: ['Bett', 'Boot'],
      phoneticRuleExplanation: 'الحرف المزدوج (ee) ينطق طويلاً ممدوداً [eː]، بينما في (Bett) ينطق الحرف (e) مفتوحاً وقصيراً [ɛ].',
    ),
    PhoneticItem(
      id: 'ph_004',
      word: 'fühlen',
      ipa: '[ˈfyːlən]',
      audioKey: 'audio_fuehlen_004',
      translationAr: 'يشعر',
      acousticDistractors: ['füllen', 'faulen'],
      phoneticRuleExplanation: 'المقطع (üh) ممدود طويل [yː]، على عكس (füllen) حيث حرف (ü) قصير ومتبوع بحرفين ساكنين.',
    ),
    PhoneticItem(
      id: 'ph_005',
      word: 'Staat',
      ipa: '[ʃtaːt]',
      audioKey: 'audio_staat_005',
      translationAr: 'دولة',
      acousticDistractors: ['Stadt', 'statt'],
      phoneticRuleExplanation: 'المقطع (aa) يدل على حركة طويلة ممدودة [aː]، بينما في (Stadt) الحركة قصيرة وسريعة [at].',
    ),
  ];

  /// Generates a randomized listening exercise.
  ListeningPhoneticsExercise generate({
    PhoneticItem? item,
    PhoneticExerciseType? forcedType,
  }) {
    final target = item ?? defaultBank[_random.nextInt(defaultBank.length)];
    final type = forcedType ?? PhoneticExerciseType.minimalPairDiscrimination;

    final options = <String>[target.word, ...target.acousticDistractors]..shuffle(_random);

    String prompt;
    switch (type) {
      case PhoneticExerciseType.minimalPairDiscrimination:
        prompt = 'استمع بدقة للمقطع الصوتي واختر الكلمة المطابقة للفظ المنطوق:';
        break;
      case PhoneticExerciseType.audioToWordMatching:
        prompt = 'أيّ من الكلمات التالية سمعتها في التسجيل الصوتي؟';
        break;
      case PhoneticExerciseType.vowelLengthIdentification:
        prompt = 'حدد الكلمة التي تطابق النطق الصوتي المسموع:';
        break;
    }

    return ListeningPhoneticsExercise(
      exerciseId: 'ph_ex_${target.id}_${_random.nextInt(10000)}',
      type: type,
      targetWord: target.word,
      targetIpa: target.ipa,
      audioKey: target.audioKey,
      questionPrompt: prompt,
      options: options,
      expectedAnswer: target.word,
      translationAr: target.translationAr,
      explanation: target.phoneticRuleExplanation,
    );
  }

  /// Validates learner's selected acoustic choice.
  ListeningValidationResult validateAnswer({
    required PhoneticItem item,
    required String submittedAnswer,
  }) {
    final normalizedSubmitted = submittedAnswer.trim().toLowerCase();
    final normalizedExpected = item.word.trim().toLowerCase();
    final isCorrect = normalizedSubmitted == normalizedExpected;

    String feedback;
    if (isCorrect) {
      feedback = 'ممتاز! تمييزك السمعي للصوتيات الألمانية دقيق للغاية.';
    } else {
      feedback = 'غير دقيق. انتبه للفرق الصوتي: ${item.phoneticRuleExplanation}';
    }

    return ListeningValidationResult(
      isCorrect: isCorrect,
      expectedAnswer: item.word,
      submittedAnswer: submittedAnswer,
      feedback: feedback,
      ipaComparison: 'اللفظ المستهدف: ${item.ipa}',
    );
  }
}
