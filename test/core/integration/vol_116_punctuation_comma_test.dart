import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_punctuation_comma_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave30_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4930 Punctuation Comma Engine Tests', () {
    test('LING-053: Missing comma before um...zu is detected and fixed', () {
      final report = GermanPunctuationCommaEngine.auditSentencePunctuation(
        'Er lernt fleißig um die Prüfung zu bestehen.',
      );

      expect(report.hasPunctuationError, isTrue);
      expect(report.triggeredRules.contains(CommaRuleCategory.mandatoryInfinitiveUmOhneStatt), isTrue);
      expect(report.correctedSentence, equals('Er lernt fleißig, um die Prüfung zu bestehen.'));
      expect(report.officialRuleCitation, contains('§ 75'));
    });

    test('LING-053: Illegal English-style comma after adverb is flagged and removed', () {
      final report = GermanPunctuationCommaEngine.auditSentencePunctuation(
        'Folglich, müssen wir den Plan anpassen.',
      );

      expect(report.hasPunctuationError, isTrue);
      expect(report.triggeredRules.contains(CommaRuleCategory.forbiddenEnglishStyleAdverbComma), isTrue);
      expect(report.correctedSentence, equals('Folglich müssen wir den Plan anpassen.'));
      expect(report.arabicExplanation, contains('متأثر بالإنجليزية'));
    });

    test('LING-053: Correct sentence passes cleanly with zero errors', () {
      final report = GermanPunctuationCommaEngine.auditSentencePunctuation(
        'Er ging nach Hause, weil es spät war.',
      );

      expect(report.hasPunctuationError, isFalse);
      expect(report.correctedSentence, equals(report.originalSentence));
    });

    test('UI Bridge generates accurate Task 4930 diagnostics report', () {
      final bridge = Vol116Wave30UIBridge();
      final report = bridge.getTask4930Diagnostics();

      expect(report['task_id'], equals(4930));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(70));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
