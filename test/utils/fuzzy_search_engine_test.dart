import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/utils/fuzzy_search_engine.dart';

void main() {
  group('Damerau-Levenshtein with edit threshold 2', () {
    test('handles insertion, deletion, substitution, and adjacent swap', () {
      expect(FuzzySearchEngine.distance('gehen', 'gehn'), 1);
      expect(FuzzySearchEngine.distance('gehn', 'gehen'), 1);
      expect(FuzzySearchEngine.distance('gehen', 'gehem'), 1);
      expect(FuzzySearchEngine.distance('haus', 'huas'), 1);
    });

    test('uses unrestricted Damerau distance, not OSA distance', () {
      expect(FuzzySearchEngine.distance('ca', 'abc'), 2);
    });

    test('handles Cyrillic and Unicode scalar values', () {
      expect(FuzzySearchEngine.distance('съел', 'сьел'), 1);
      expect(FuzzySearchEngine.distance('a😀b', 'a😀c'), 1);
    });

    test('rejects edits beyond the strict threshold', () {
      expect(FuzzySearchEngine.distance('gehen', 'xyz'), isNull);
      expect(FuzzySearchEngine.distance('haus', 'haus'), 0);
    });

    test('refuses oversized tokens without computing a matrix', () {
      final longText = List<String>.filled(
        FuzzySearchEngine.maxTermLength + 1,
        'a',
      ).join();
      expect(FuzzySearchEngine.distance(longText, 'a'), isNull);
      expect(FuzzySearchEngine.distance('a', longText), isNull);
    });
  });

  group('Latin phonetic clustering', () {
    test('standard Soundex matches similar pronunciations', () {
      expect(FuzzySearchEngine.soundex('Robert'), 'R163');
      expect(FuzzySearchEngine.soundex('Rupert'), 'R163');
      expect(FuzzySearchEngine.soundex('Ashcraft'), 'A261');
    });

    test('folds common Latin accents but not non-Latin scripts', () {
      expect(FuzzySearchEngine.soundex('Müller'), isNotNull);
      expect(FuzzySearchEngine.soundex('съел'), isNull);
      expect(FuzzySearchEngine.soundex('你好'), isNull);
      expect(FuzzySearchEngine.soundex(''), isNull);
      expect(FuzzySearchEngine.soundex('  '), isNull);
    });
  });

  group('Did you mean suggestions', () {
    test('returns at most three bounded edit-distance candidates', () {
      final suggestions = FuzzySearchEngine.suggest(
        'gehn',
        <String>['gehen', 'gehnn', 'gehne', 'gegessen', 'gehen'],
      );
      expect(suggestions.length, lessThanOrEqualTo(3));
      expect(suggestions.map((item) => item.term), contains('gehen'));
      expect(suggestions.every((item) => item.distance <= 2), isTrue);
    });

    test('does not return suggestions if exact/prefix search succeeded', () {
      expect(
        FuzzySearchEngine.suggest(
          'gehn',
          <String>['gehen'],
          hasExactOrPrefixMatches: true,
        ),
        isEmpty,
      );
    });

    test('does not suggest the identical term or duplicate spellings', () {
      final result = FuzzySearchEngine.suggest(
        'robert',
        <String>['Robert', 'Rupert', 'RUPERT', 'rupert'],
      );
      expect(result.map((item) => item.term).toList(), <String>['Rupert']);
      expect(result.single.phoneticMatch, isTrue);
    });

    test('caps inspected candidate count to limit synchronous CPU work', () {
      final candidates = <String>[
        ...List<String>.filled(FuzzySearchEngine.maxCandidates, 'xxxxxxxx'),
        'gehen',
      ];
      expect(FuzzySearchEngine.suggest('gehn', candidates), isEmpty);
    });

    test('rejects oversized query and enforces requested limit', () {
      final oversized = List<String>.filled(
        FuzzySearchEngine.maxTermLength + 1,
        'a',
      ).join();
      expect(FuzzySearchEngine.suggest(oversized, <String>['a']), isEmpty);
      expect(
        FuzzySearchEngine.suggest(
          'catt',
          <String>['cat', 'cart', 'cast', 'coat'],
          limit: 1,
        ).length,
        1,
      );
    });
  });
}
