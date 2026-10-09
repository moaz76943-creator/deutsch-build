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
  });

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
    };
  }

  factory VocabularyItem.fromJson(Map<dynamic, dynamic> json) {
    return VocabularyItem(
      word: json['word'] ?? '',
      article: json['article'] ?? 'der',
      plural: json['plural'] ?? '',
      preposition: json['preposition'] ?? '',
      collocation: json['collocation'] ?? '',
      wordFamily: json['wordFamily'] ?? '',
      difficultyScore: (json['difficultyScore'] as num?)?.toDouble() ?? 1.0,
      meaning: json['meaning'] ?? '',
      example: json['example'] ?? '',
    );
  }
}
