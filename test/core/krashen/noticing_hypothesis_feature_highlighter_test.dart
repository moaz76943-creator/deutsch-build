import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/krashen/noticing_hypothesis_feature_highlighter.dart';

void main() {
  group('NoticingHypothesisFeatureHighlighter Suite', () {
    const highlighter = NoticingHypothesisFeatureHighlighter();

    test('Enhances Arabic target dual suffix morphemes with markdown bolding', () {
      const sentence = 'حضر المعلمان الجديدان إلى المدرسة';
      final enhanced = highlighter.highlightTargetFeatures(
        sentence: sentence,
        targetMorphemes: ['ان'],
        grammarRuleTitle: 'علامة تثنية الاسم المرفوع',
        mode: TypographicalEnhancementMode.subtleBold,
      );

      expect(enhanced.spans.length, equals(2));
      expect(enhanced.renderedMarkup, contains('المعلم**ان**'));
      expect(enhanced.renderedMarkup, contains('الجديد**ان**'));
      expect(enhanced.originalText, equals(sentence));
    });

    test('Enhances Turkish past tense suffix using underline tag', () {
      const sentence = 'Dün güzel bir kitap okudu.';
      final enhanced = highlighter.highlightTargetFeatures(
        sentence: sentence,
        targetMorphemes: ['du'],
        grammarRuleTitle: 'Görülen Geçmiş Zaman',
        mode: TypographicalEnhancementMode.underlinedTarget,
      );

      expect(enhanced.spans.length, equals(1));
      expect(enhanced.renderedMarkup, contains('oku<u>du</u>.'));
    });
  });
}
