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
  final String semanticField; // الحقل المعرفي الدلالي (طبي، أكاديمي، حياة يومية، إلخ)

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
  });

  bool get isReviewDue => interval <= 1;

  String get texturalMnemonic {
    if (languageCode == 'de') {
      switch (article.toLowerCase()) {
        case 'der':
          return 'مادة صلبة ولامعة (مذكر ألماني)';
        case 'die':
          return 'مادة عضوية وناعمة (مؤنث ألماني)';
        case 'das':
          return 'مادة هادئة ومستقرة (محايد ألماني)';
        default:
          return 'هيكل محايد';
      }
    }
    return 'مفردة كونية دلالية (${languageCode.toUpperCase()})';
  }

  String get satzklammerVisualization {
    if (languageCode == 'de') {
      if (preposition.isNotEmpty) {
        return 'قوس الجملة: [فعل متصرف] ... [حرف الجر مع ${word}]';
      }
      return 'قوس الجملة: [فعل متصرف] ... [${article} ${word} في النهاية]';
    }
    return 'هيكل بنيوي متناسق (${languageCode.toUpperCase()})';
  }

  VocabularyItem calculateSm2(int quality) {
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
        newInterval = (interval * newEase).round();
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
    };
  }

  factory VocabularyItem.fromJson(Map<dynamic, dynamic> json) {
    return VocabularyItem(
      word: json['word'] ?? '',
      article: json['article'] ?? '',
      plural: json['plural'] ?? '',
      preposition: json['preposition'] ?? '',
      collocation: json['collocation'] ?? '',
      wordFamily: json['wordFamily'] ?? '',
      difficultyScore: (json['difficultyScore'] as num?)?.toDouble() ?? 1.0,
      meaning: json['meaning'] ?? '',
      example: json['example'] ?? '',
      interval: json['interval'] ?? 0,
      repetitions: json['repetitions'] ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      languageCode: json['languageCode'] ?? 'de',
      etymologyRoot: json['etymologyRoot'] ?? '',
      semanticField: json['semanticField'] ?? 'حياة يومية',
    );
  }
}
