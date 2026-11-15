import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/dialogue/grammatical_error_correction_engine.dart';

void main() {
  group('GrammaticalErrorCorrectionEngine Tests', () {
    const engine = GrammaticalErrorCorrectionEngine();

    test('Corrects subordinate clause verb placement after "weil"', () {
      const input = 'Ich lerne Deutsch, weil ich gehe nach Deutschland.';
      final corrections = engine.analyzeSentence(input);

      expect(corrections.isNotEmpty, isTrue);
      final c = corrections.first;
      expect(c.errorType, equals(GrammarErrorType.subordinateClauseWordOrder));
      expect(c.correctedFullSentence, contains('weil ich nach Deutschland gehe'));
      expect(c.ruleExplanation, contains('finite verb must go to the very end'));
    });

    test('Corrects subject-verb agreement for first-person singular', () {
      const input = 'Heute ich geht ins Kino.';
      final corrections = engine.analyzeSentence(input);

      expect(corrections.any((c) => c.errorType == GrammarErrorType.subjectVerbAgreement), isTrue);
      final c = corrections.firstWhere((c) => c.errorType == GrammarErrorType.subjectVerbAgreement);
      expect(c.correctedSegment, equals('ich gehe'));
    });

    test('Corrects masculine accusative case mistake', () {
      const input = 'Ich sehe der Mann.';
      final corrections = engine.analyzeSentence(input);

      expect(corrections.any((c) => c.errorType == GrammarErrorType.caseGenderMismatch), isTrue);
      final c = corrections.firstWhere((c) => c.errorType == GrammarErrorType.caseGenderMismatch);
      expect(c.correctedSegment, equals('den'));
    });

    test('Passes clean grammatical sentence with zero corrections', () {
      const clean = 'Ich lerne jeden Tag Deutsch, weil es mir Spaß macht.';
      final corrections = engine.analyzeSentence(clean);
      expect(corrections, isEmpty);
    });
  });
}
