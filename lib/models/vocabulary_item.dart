class VocabularyItem {
  final String word;
  final String article;
  final String plural;
  final String preposition;
  final String collocation;
  final String wordFamily;
  final double difficultyScore;
  final String meaning;
  final String example;
  final int interval;
  final int repetitions;
  final double easeFactor;
  final String languageCode;
  final String etymologyRoot;
  final String semanticField;
  final String professionalContext;
  final String grammaticalValency;
  final String pragmaticScenario;
  final String cognateNote;
  final String morphologicalTree;
  final String morphophonemicBridge;
  final String
      politenessRegister; // مؤشر مستويات الخطاب والطبقات الاجتماعية (رسمي، مهني، يومي)

  VocabularyItem({
    required this.word,
    required this.article,
    required this.plural,
    required this.preposition,
    required this.collocation,
    required this.wordFamily,
    required this.difficultyScore,
    required this.meaning,
    required this.example,
    this.interval = 0,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.languageCode = 'de',
    this.etymologyRoot = '',
    this.semanticField = 'حياة يومية',
    this.professionalContext = 'عام',
    this.grammaticalValency = '',
    this.pragmaticScenario = '',
    this.cognateNote = '',
    this.morphologicalTree = '',
    this.morphophonemicBridge = '',
    this.politenessRegister = 'محايد / يومي',
  });

  bool get isReviewDue => interval <= 1;

  String get languageFamilyGroup {
    if (languageCode == 'de' || languageCode == 'en') return 'جرمانية';
    if (languageCode == 'fr' || languageCode == 'es') return 'رومانسية';
    return 'كونية عامة';
  }

  VocabularyItem calculateSm2(int quality) {
    double adaptiveDecayFactor = (quality < 3) ? 0.8 : 1.0;
    double newEase =
        easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (newEase < 1.3) newEase = 1.3;

    int newRepetitions = repetitions;
    int newInterval = interval;

    if (quality >= 3) {
      if (newRepetitions == 0) {
        newInterval = 1;
      } else if (newRepetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (interval * newEase * adaptiveDecayFactor).round();
      }
      newRepetitions++;
    } else {
      newRepetitions = 0;
      newInterval = 1;
    }

    return VocabularyItem(
      word: word,
      article: article,
      plural: plural,
      preposition: preposition,
      collocation: collocation,
      wordFamily: wordFamily,
      difficultyScore: difficultyScore,
      meaning: meaning,
      example: example,
      interval: newInterval,
      repetitions: newRepetitions,
      easeFactor: newEase,
      languageCode: languageCode,
      etymologyRoot: etymologyRoot,
      semanticField: semanticField,
      professionalContext: professionalContext,
      grammaticalValency: grammaticalValency,
      pragmaticScenario: pragmaticScenario,
      cognateNote: cognateNote,
      morphologicalTree: morphologicalTree,
      morphophonemicBridge: morphophonemicBridge,
      politenessRegister: politenessRegister,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'article': article,
      'plural': plural,
      'preposition': preposition,
      'collocation': collocation,
      'wordFamily': wordFamily,
      'difficultyScore': difficultyScore,
      'meaning': meaning,
      'example': example,
      'interval': interval,
      'repetitions': repetitions,
      'easeFactor': easeFactor,
      'languageCode': languageCode,
      'etymologyRoot': etymologyRoot,
      'semanticField': semanticField,
      'professionalContext': professionalContext,
      'grammaticalValency': grammaticalValency,
      'pragmaticScenario': pragmaticScenario,
      'cognateNote': cognateNote,
      'morphologicalTree': morphologicalTree,
      'morphophonemicBridge': morphophonemicBridge,
      'politenessRegister': politenessRegister,
    };
  }

  factory VocabularyItem.fromJson(Map<dynamic, dynamic> json) {
    try {
      return VocabularyItem(
        word: json['word']?.toString() ?? '',
        article: json['article']?.toString() ?? '',
        plural: json['plural']?.toString() ?? '',
        preposition: json['preposition']?.toString() ?? '',
        collocation: json['collocation']?.toString() ?? '',
        wordFamily: json['wordFamily']?.toString() ?? '',
        difficultyScore:
            double.tryParse(json['difficultyScore']?.toString() ?? '') ?? 1.0,
        meaning: json['meaning']?.toString() ?? '',
        example: json['example']?.toString() ?? '',
        interval: int.tryParse(json['interval']?.toString() ?? '') ?? 0,
        repetitions: int.tryParse(json['repetitions']?.toString() ?? '') ?? 0,
        easeFactor:
            double.tryParse(json['easeFactor']?.toString() ?? '') ?? 2.5,
        languageCode: json['languageCode']?.toString() ?? 'de',
        etymologyRoot: json['etymologyRoot']?.toString() ?? '',
        semanticField: json['semanticField']?.toString() ?? 'حياة يومية',
        professionalContext: json['professionalContext']?.toString() ?? 'عام',
        grammaticalValency: json['grammaticalValency']?.toString() ?? '',
        pragmaticScenario: json['pragmaticScenario']?.toString() ?? '',
        cognateNote: json['cognateNote']?.toString() ?? '',
        morphologicalTree: json['morphologicalTree']?.toString() ?? '',
        morphophonemicBridge: json['morphophonemicBridge']?.toString() ?? '',
        politenessRegister:
            json['politenessRegister']?.toString() ?? 'محايد / يومي',
      );
    } catch (_) {
      return VocabularyItem(
        word: 'fallback',
        article: '',
        plural: '',
        preposition: '',
        collocation: '',
        wordFamily: '',
        difficultyScore: 1.0,
        meaning: '',
        example: '',
      );
    }
  }
}
