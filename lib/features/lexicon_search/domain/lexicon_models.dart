enum LexiconArticle { der, die, das, none }

final class LexiconSearchFilters {
  const LexiconSearchFilters({
    this.cefrLevels = const <String>{},
    this.articles = const <LexiconArticle>{},
  });

  final Set<String> cefrLevels;
  final Set<LexiconArticle> articles;

  bool get isEmpty => cefrLevels.isEmpty && articles.isEmpty;

  LexiconSearchFilters copyWith({
    Set<String>? cefrLevels,
    Set<LexiconArticle>? articles,
  }) {
    return LexiconSearchFilters(
      cefrLevels: cefrLevels ?? this.cefrLevels,
      articles: articles ?? this.articles,
    );
  }
}

final class LexiconSearchQuery {
  const LexiconSearchQuery({
    this.text = '',
    this.filters = const LexiconSearchFilters(),
    this.limit = 80,
  }) : assert(limit > 0 && limit <= 200);

  final String text;
  final LexiconSearchFilters filters;
  final int limit;

  LexiconSearchQuery copyWith({
    String? text,
    LexiconSearchFilters? filters,
    int? limit,
  }) {
    return LexiconSearchQuery(
      text: text ?? this.text,
      filters: filters ?? this.filters,
      limit: limit ?? this.limit,
    );
  }
}

final class SearchResultItem {
  const SearchResultItem({
    required this.wordId,
    required this.germanWord,
    required this.arabicMeaning,
    required this.cefrLevel,
    this.article = LexiconArticle.none,
  });

  final String wordId;
  final String germanWord;
  final LexiconArticle article;
  final String arabicMeaning;
  final String cefrLevel;

  bool get hasArticle => article != LexiconArticle.none;

  String get articleLabel => switch (article) {
        LexiconArticle.der => 'der',
        LexiconArticle.die => 'die',
        LexiconArticle.das => 'das',
        LexiconArticle.none => '',
      };
}

final class UserBookmark {
  const UserBookmark({
    required this.wordId,
    required this.addedAt,
    this.collections = const <String>[],
  });

  final String wordId;
  final DateTime addedAt;
  final List<String> collections;

  UserBookmark copyWith({
    DateTime? addedAt,
    List<String>? collections,
  }) {
    return UserBookmark(
      wordId: wordId,
      addedAt: addedAt ?? this.addedAt,
      collections: collections ?? this.collections,
    );
  }
}

final class WordPersonalNote {
  const WordPersonalNote({
    required this.wordId,
    required this.note,
    required this.updatedAt,
    this.examples = const <String>[],
  });

  final String wordId;
  final String note;
  final List<String> examples;
  final DateTime updatedAt;
}
