class VocabularyItem {
  final String word;
  final String article;
  final String plural;
  final String preposition;
  final String meaning;
  final String example;

  VocabularyItem({
    required this.word,
    required this.article,
    required this.plural,
    required this.preposition,
    required this.meaning,
    required this.example,
  });

  Map<String, String> toJson() {
    return {
      'word': word,
      'article': article,
      'plural': plural,
      'preposition': preposition,
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
      meaning: json['meaning'] ?? '',
      example: json['example'] ?? '',
    );
  }
}
