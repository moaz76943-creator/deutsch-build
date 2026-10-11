import 'package:deutsch_bilarabi/utils/fuzzy_search_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('true bounded Damerau-Levenshtein', () {
    test('supports insertion, deletion, replacement, and transposition', () {
      expect(FuzzySearchEngine.damerauLevenshtein('boook', 'book'), 1);
      expect(FuzzySearchEngine.damerauLevenshtein('bok', 'book'), 1);
      expect(FuzzySearchEngine.damerauLevenshtein('back', 'book'), 2);
      expect(FuzzySearchEngine.damerauLevenshtein('wrod', 'word'), 1);
      expect(FuzzySearchEngine.damerauLevenshtein('CA', 'ABC'), 2);
    });

    test('distance over two is capped and oversized strings are rejected', () {
      expect(FuzzySearchEngine.damerauLevenshtein('abc', 'uvwxyz'), 3);
      expect(FuzzySearchEngine.damerauLevenshtein(List<String>.filled(49, 'a').join(), 'a'), 3);
      expect(FuzzySearchEngine.damerauLevenshtein('', ''), 0);
      expect(FuzzySearchEngine.damerauLevenshtein('', 'xy'), 2);
    });

    test('Unicode code points and case-insensitive matching', () {
      expect(FuzzySearchEngine.damerauLevenshtein('Ging', 'ging'), 0);
      expect(FuzzySearchEngine.damerauLevenshtein('über', 'über'), 0);
      expect(FuzzySearchEngine.damerauLevenshtein('über', 'uber'), 1);
    });
  });

  group('Latin phonetic suggestions', () {
    test('Soundex groups Latin spelling variants', () {
      expect(FuzzySearchEngine.soundex('Robert'), 'R163');
      expect(FuzzySearchEngine.soundex('Rupert'), 'R163');
      expect(FuzzySearchEngine.soundex('Smith'),
          FuzzySearchEngine.soundex('Smyth'));
      expect(FuzzySearchEngine.soundex('纸'), isEmpty);
      expect(FuzzySearchEngine.soundex(List<String>.filled(49, 'a').join()), isEmpty);
    });

    test('offers at most top three deterministically', () {
      final results = FuzzySearchEngine.didYouMean(
        'wrod',
        <String>['worlds', 'ward', 'word', 'wood', 'worst', 'word'],
      );
      expect(results, hasLength(3));
      expect(results.first, 'word');
      expect(results.toSet().length, 3);
    });

    test('phonetic clustering never bypasses the two-edit threshold', () {
      expect(
        FuzzySearchEngine.soundex('robert'),
        FuzzySearchEngine.soundex('rooooobert'),
      );
      expect(
        FuzzySearchEngine.didYouMean('robert', <String>['rooooobert']),
        isEmpty,
      );
    });

    test('does not suggest when exact/prefix results exist', () {
      expect(
        FuzzySearchEngine.didYouMean(
          'word',
          <String>['ward', 'wood'],
          exactOrPrefixFound: true,
        ),
        isEmpty,
      );
      expect(
        FuzzySearchEngine.didYouMean('wor', <String>['word', 'ward']),
        isEmpty,
      );
    });

    test('queries longer than 30 characters are rejected', () {
      final query = List<String>.filled(31, 'a').join();
      expect(FuzzySearchEngine.didYouMean(query, <String>['apple']), isEmpty);
      expect(FuzzySearchEngine.damerauLevenshtein(query, 'apple'), 3);
    });

    test('respects bounded input and candidate scan size', () {
      final candidates = <String>[
        for (var i = 0; i < FuzzySearchEngine.maxCandidateChecks; i++)
          'zzzzzz$i',
        'word',
      ];
      expect(FuzzySearchEngine.didYouMean('wrod', candidates), isEmpty);
      expect(
        FuzzySearchEngine.didYouMean(List<String>.filled(49, 'a').join(), <String>['a']),
        isEmpty,
      );
    });

    test('falls back to edit distance for non-Latin text', () {
      expect(FuzzySearchEngine.didYouMean('كتتب', <String>['كتاب']), <String>['كتاب']);
    });
  });
}
