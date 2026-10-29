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
  final String politenessRegister; // مؤشر مستويات الخطاب والطبقات الاجتماعية (رسمي، مهني، يومي)
  final String imageUrl;

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
    this.imageUrl = '',
  });

  bool get isReviewDue => interval <= 1;

  String get languageFamilyGroup {
    if (languageCode == 'de' || languageCode == 'en') return 'جرمانية';
    if (languageCode == 'fr' || languageCode == 'es') return 'رومانسية';
    return 'كونية عامة';
  }

  VocabularyItem calculateSm2(int quality) {
    double adaptiveDecayFactor = (quality < 3) ? 0.8 : 1.0;
    double newEase = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
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
      imageUrl: imageUrl,
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
      'Image_URL': imageUrl,
    };
  }

  factory VocabularyItem.fromJson(Map<dynamic, dynamic> json) {
    return VocabularyItem(
      word: json['word'] as String? ?? '',
      article: json['article'] as String? ?? '',
      plural: json['plural'] as String? ?? '',
      preposition: json['preposition'] as String? ?? '',
      collocation: json['collocation'] as String? ?? '',
      wordFamily: json['wordFamily'] as String? ?? '',
      difficultyScore: (json['difficultyScore'] as num?)?.toDouble() ?? 1.0,
      meaning: json['meaning'] as String? ?? '',
      example: json['example'] as String? ?? '',
      interval: json['interval'] as int? ?? 0,
      repetitions: json['repetitions'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      languageCode: json['languageCode'] as String? ?? 'de',
      etymologyRoot: json['etymologyRoot'] as String? ?? '',
      semanticField: json['semanticField'] as String? ?? 'حياة يومية',
      professionalContext: json['professionalContext'] as String? ?? 'عام',
      grammaticalValency: json['grammaticalValency'] as String? ?? '',
      pragmaticScenario: json['pragmaticScenario'] as String? ?? '',
      cognateNote: json['cognateNote'] as String? ?? '',
      morphologicalTree: json['morphologicalTree'] as String? ?? '',
      morphophonemicBridge: json['morphophonemicBridge'] as String? ?? '',
      politenessRegister: json['politenessRegister'] as String? ?? 'محايد / يومي',
      imageUrl: json['Image_URL'] as String? ?? '',
    );
  }
}
