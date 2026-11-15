import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/multimodal_dialogue/non_verbal_acoustic_synthesizer.dart';

void main() {
  group('NonVerbalAcousticSynthesizer Unit Tests (N072)', () {
    final synthesizer = NonVerbalAcousticSynthesizer();

    test('Injects playful chuckle when conversation context is humorous', () {
      final cue = synthesizer.selectCueForContext(
        isPonderingComplexGrammar: false,
        isAmusedOrPlayful: true,
        isConfirmingUnderstanding: false,
      );

      expect(cue, isNotNull);
      expect(cue!.type, equals(NonVerbalCueType.gentleChuckle));
      final fullText = synthesizer.prependCue('Das ist ja witzig!', cue);
      expect(fullText, contains('(leises Lachen) Das ist ja witzig!'));
    });

    test('Injects thoughtful hum when pondering complex linguistic questions', () {
      final cue = synthesizer.selectCueForContext(
        isPonderingComplexGrammar: true,
        isAmusedOrPlayful: false,
        isConfirmingUnderstanding: false,
      );

      expect(cue?.type, equals(NonVerbalCueType.thoughtfulHum));
      expect(cue?.textRepresentation, contains('Hmm...'));
    });

    test('Returns null when no non-verbal cue is required', () {
      final cue = synthesizer.selectCueForContext(
        isPonderingComplexGrammar: false,
        isAmusedOrPlayful: false,
        isConfirmingUnderstanding: false,
      );
      expect(cue, isNull);
    });
  });
}
