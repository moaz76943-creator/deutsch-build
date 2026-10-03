import 'package:deutsch_bilarabi/features/search/data/lexicon_search_repository.dart';
import 'package:deutsch_bilarabi/features/search/data/search_text_normalizer.dart';
import 'package:deutsch_bilarabi/features/search/domain/search_models.dart';
import 'package:deutsch_bilarabi/language/german/german_text_normalizer.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/services/search_index.dart';
import 'package:deutsch_bilarabi/services/verb_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizer = GermanTextNormalizer();
  final items = <ContentItem>[
    const ContentItem(
      id: 'buecher',
      german: 'Bücher',
      arabic: 'كتب',
      sentence: 'Die Bücher sind neu.',
      sentenceAr: 'الكتب جديدة.',
      topic: 'Alltag',
      skill: 'vocab',
      article: 'die',
      plural: 'Bücher',
    ),
    const ContentItem(
      id: 'baum',
      german: 'Baum',
      arabic: 'شجرة',
      sentence: 'Der Baum ist groß.',
      sentenceAr: 'الشجرة كبيرة.',
      topic: 'Natur',
      skill: 'vocab',
      article: 'der',
    ),
    const ContentItem(
      id: 'haus',
      german: 'Haus',
      arabic: 'منزل',
      sentence: 'Das Haus ist alt.',
      sentenceAr: 'المنزل قديم.',
      topic: 'Alltag',
      skill: 'vocab',
      article: 'das',
    ),
    const ContentItem(
      id: 'suchen',
      german: 'suchen',
      arabic: 'يبحث',
      sentence: 'Ich suche den Schlüssel.',
      sentenceAr: 'أبحث عن المفتاح.',
      topic: 'Alltag',
      skill: 'verb',
    ),
  ];
  final verbIndex = VerbIndex(textNormalizer: normalizer);
  late LexiconSearchRepository<ContentItem> repository;

  setUp(() {
    repository = LexiconSearchRepository<ContentItem>(
      index: SearchIndex<ContentItem>(items, verbIndex, normalizer),
      corpus: items,
    );
  });

  test('normalizer exposes umlaut transliteration and folded latin aliases', () {
    expect(
      SearchTextNormalizer.variants('Bücher'),
      containsAll(<String>{'bücher', 'buecher', 'bucher'}),
    );
  });

  test('search matches umlaut word from buecher and bucher input', () async {
    final transliterated =
        await repository.search(const SearchQuery(text: 'buecher'));
    final folded = await repository.search(const SearchQuery(text: 'bucher'));

    expect(transliterated.map((item) => item.id), contains('buecher'));
    expect(folded.map((item) => item.id), contains('buecher'));
  });

  test('search delegates Arabic lookup to the canonical search index', () async {
    final results = await repository.search(const SearchQuery(text: 'كتب'));
    expect(results.first.id, 'buecher');
  });

  test('filters distinguish verbs nouns and article classes', () async {
    final verbs = await repository.search(
      const SearchQuery(filters: <SearchFilter>{SearchFilter.verbs}),
    );
    final derNouns = await repository.search(
      const SearchQuery(
        filters: <SearchFilter>{SearchFilter.nouns, SearchFilter.der},
      ),
    );
    final dieNouns = await repository.search(
      const SearchQuery(filters: <SearchFilter>{SearchFilter.die}),
    );
    final dasNouns = await repository.search(
      const SearchQuery(filters: <SearchFilter>{SearchFilter.das}),
    );

    expect(verbs.map((item) => item.id), <String>['suchen']);
    expect(derNouns.map((item) => item.id), <String>['baum']);
    expect(dieNouns.map((item) => item.id), <String>['buecher']);
    expect(dasNouns.map((item) => item.id), <String>['haus']);
  });
}
