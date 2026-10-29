import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/dtw_speech_text_aligner.dart';

void main() {
  group('DtwSpeechTextAligner Tests', () {
    const aligner = DtwSpeechTextAligner();

    test('Aligns identical token sequences with 100% match rate', () {
      final ref = ['Ich', 'gehe', 'nach', 'Hause'];
      final spoken = ['Ich', 'gehe', 'nach', 'Hause'];

      final report = aligner.align(referenceTokens: ref, spokenTokens: spoken);

      expect(report.sentenceMatchPercentage, equals(100.0));
      expect(report.missingTokensCount, equals(0));
      expect(report.matchingTokensCount, equals(4));
    });

    test('Detects deleted/skipped word in spoken sentence', () {
      final ref = ['Ich', 'gehe', 'nach', 'Hause'];
      final spoken = ['Ich', 'nach', 'Hause']; // 'gehe' was skipped

      final report = aligner.align(referenceTokens: ref, spokenTokens: spoken);

      expect(report.missingTokensCount, equals(1));
      expect(report.sentenceMatchPercentage, equals(75.0));
      expect(report.alignedPairs.any((p) => p.operation == AlignmentOperation.deletion), isTrue);
    });
  });
}
