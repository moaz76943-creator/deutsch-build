/// German noun articles are a German-language concern and must never become a
/// universal gender/article schema for other languages.
enum GermanArticle { der, die, das }

final class GermanArticleStyle {
  final GermanArticle article;
  final String gender;
  final int colorArgb;
  final String colorToken;

  const GermanArticleStyle._({
    required this.article,
    required this.gender,
    required this.colorArgb,
    required this.colorToken,
  });

  static const GermanArticleStyle der = GermanArticleStyle._(
    article: GermanArticle.der,
    gender: 'masculine',
    colorArgb: 0xFF1976D2,
    colorToken: 'germanArticle.der',
  );

  static const GermanArticleStyle die = GermanArticleStyle._(
    article: GermanArticle.die,
    gender: 'feminine',
    colorArgb: 0xFFD32F2F,
    colorToken: 'germanArticle.die',
  );

  static const GermanArticleStyle das = GermanArticleStyle._(
    article: GermanArticle.das,
    gender: 'neuter',
    colorArgb: 0xFF388E3C,
    colorToken: 'germanArticle.das',
  );

  static GermanArticleStyle forGermanNoun({
    required String languageCode,
    required String article,
  }) {
    final language =
        languageCode.trim().toLowerCase().split(RegExp(r'[-_]')).first;
    if (language != 'de') {
      throw ArgumentError('German article styling is only valid for German');
    }
    return switch (article.trim().toLowerCase()) {
      'der' => der,
      'die' => die,
      'das' => das,
      _ => throw FormatException('unsupported German article: $article'),
    };
  }
}
