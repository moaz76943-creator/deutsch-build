enum SearchItemType { verb, noun, other }

enum GermanArticle { der, die, das, none }

enum SearchFilter { verbs, nouns, der, die, das }

final class SearchQuery {
  const SearchQuery({
    this.text = '',
    this.filters = const <SearchFilter>{},
    this.limit = 80,
  }) : assert(limit > 0);

  final String text;
  final Set<SearchFilter> filters;
  final int limit;

  SearchQuery copyWith({
    String? text,
    Set<SearchFilter>? filters,
    int? limit,
  }) =>
      SearchQuery(
        text: text ?? this.text,
        filters: filters ?? this.filters,
        limit: limit ?? this.limit,
      );
}

final class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.term,
    required this.translationArabic,
    required this.type,
    this.article = GermanArticle.none,
    this.aliases = const <String>[],
  });

  final String id;
  final String term;
  final String translationArabic;
  final SearchItemType type;
  final GermanArticle article;
  final List<String> aliases;

  bool get hasArticle => article != GermanArticle.none;

  String get articleLabel => switch (article) {
        GermanArticle.der => 'der',
        GermanArticle.die => 'die',
        GermanArticle.das => 'das',
        GermanArticle.none => '',
      };
}

final class UserBookmark {
  const UserBookmark({
    required this.item,
    this.createdAt,
  });

  final SearchResultItem item;
  final DateTime? createdAt;
}

final class CustomWordNote {
  const CustomWordNote({
    required this.wordId,
    required this.text,
    required this.updatedAt,
  });

  final String wordId;
  final String text;
  final DateTime updatedAt;
}
