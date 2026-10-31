import 'package:deutsch_bilarabi/utils/word_segmenter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WordSegmenter.detectScript', () {
    test('detects Han text', () {
      expect(
        WordSegmenter.detectScript('中文测试'),
        WordScript.han,
      );
    });

    test('prefers Japanese when Kana is mixed with Kanji', () {
      expect(
        WordSegmenter.detectScript('日本語の勉強'),
        WordScript.japanese,
      );
    });

    test('detects Thai, Khmer, and Lao text', () {
      expect(
        WordSegmenter.detectScript('ภาษาไทย'),
        WordScript.thai,
      );
      expect(
        WordSegmenter.detectScript('ភាសាខ្មែរ'),
        WordScript.khmer,
      );
      expect(
        WordSegmenter.detectScript('ພາສາລາວ'),
        WordScript.lao,
      );
    });

    test('uses whitespace-delimited fallback for Latin text', () {
      expect(
        WordSegmenter.detectScript('Deutsch lernen'),
        WordScript.whitespaceDelimited,
      );
    });
  });

  group('WordSegmenter.tokenize', () {
    test('splits whitespace languages on whitespace and punctuation', () {
      expect(
        WordSegmenter.tokenize('Hallo, Welt! 42-mal.'),
        <String>['Hallo', 'Welt', '42', 'mal'],
      );
    });

    test('uses longest lexicon prefix for Han text', () {
      final tokens = WordSegmenter.tokenize(
        '研究生命起源',
        lexicon: <String>{'研究', '研究生', '生命', '命', '起源'},
        maxNGramLength: 3,
      );

      expect(tokens, <String>['研究生', '命', '起源']);
    });

    test('segments Japanese text with dictionary surface forms', () {
      final tokens = WordSegmenter.tokenize(
        '私は学生です',
        lexicon: <String>{'私', 'は', '学生', 'です'},
        maxNGramLength: 2,
      );

      expect(tokens, <String>['私', 'は', '学生', 'です']);
    });

    test('segments Thai text and preserves combining marks', () {
      expect(
        WordSegmenter.tokenize(
          'ภาษาไทย',
          lexicon: <String>{'ภาษา', 'ไทย'},
          maxNGramLength: 4,
        ),
        <String>['ภาษา', 'ไทย'],
      );

      expect(
        WordSegmenter.tokenize(
          'ก่า',
          lexicon: <String>{'ก่า'},
          maxNGramLength: 2,
        ),
        <String>['ก่า'],
      );
    });

    test('falls back to character-level units for unknown Han words', () {
      expect(
        WordSegmenter.tokenize('未知词'),
        <String>['未', '知', '词'],
      );
    });

    test('does not bridge punctuation when matching continuous scripts', () {
      expect(
        WordSegmenter.tokenize(
          '中文、测试',
          lexicon: <String>{'中文测试', '中文', '测试'},
          maxNGramLength: 4,
        ),
        <String>['中文', '测试'],
      );
    });
  });

  group('WordSegmenter.extractCandidates', () {
    test('returns longest-first bounded n-gram candidates', () {
      final candidates = WordSegmenter.extractCandidates(
        '中文测试',
        maxNGramLength: 3,
        maxCandidates: 6,
      );

      expect(candidates.first, '中文测');
      expect(candidates, contains('中文'));
      expect(candidates.length, lessThanOrEqualTo(6));
    });

    test('returns normal tokens for whitespace-delimited text', () {
      expect(
        WordSegmenter.extractCandidates('one, two three'),
        <String>['one', 'two', 'three'],
      );
    });
  });

  group('WordSegmenter bounds', () {
    test('rejects inputs beyond the bounded code-point limit', () {
      final oversized = List<String>.filled(
        WordSegmenter.maxInputCodePoints + 1,
        '中',
      ).join();

      expect(
        () => WordSegmenter.tokenize(oversized),
        throwsRangeError,
      );
    });

    test('rejects unbounded n-gram and candidate limits', () {
      expect(
        () => WordSegmenter.tokenize(
          '中文',
          maxNGramLength: WordSegmenter.maxNGramLengthLimit + 1,
        ),
        throwsRangeError,
      );
      expect(
        () => WordSegmenter.extractCandidates(
          '中文',
          maxCandidates: WordSegmenter.maxCandidateLimit + 1,
        ),
        throwsRangeError,
      );
    });
  });
}
