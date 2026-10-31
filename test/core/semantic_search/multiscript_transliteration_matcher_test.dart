import 'package:test/test.dart';
import '../../lib/src/core/semantic_search/multiscript_transliteration_matcher.dart';

void main() {
  group('MultiScriptTransliterationMatcher Unit Tests (N054)', () {
    final matcher = MultiScriptTransliterationMatcher();

    test('Transliterates Arabizi numbers and digraphs to Arabic script', () {
      expect(matcher.transliterateArabizi('3arab'), equals('عرب'));
      expect(matcher.transliterateArabizi('shukran'), equals('شكران'));
      expect(matcher.transliterateArabizi('7abibi'), equals('حبيبي'));
    });

    test('Matches Arabizi query against Arabic candidate text with high confidence', () {
      final scoreExact = matcher.matchQuery(query: '3arab', candidate: 'عرب');
      expect(scoreExact, equals(1.0));

      final scorePartial = matcher.matchQuery(query: 'shukran', candidate: 'شكراً جزيلاً');
      expect(scorePartial, greaterThanOrEqualTo(0.85));
    });

    test('Returns 0.0 for unrelated mismatch', () {
      expect(matcher.matchQuery(query: 'kitab', candidate: 'سيارة'), equals(0.0));
    });
  });
}
