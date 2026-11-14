import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_indirect_questions_imperatives_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave16_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4916 Indirect Questions & Imperatives Engine Tests', () {
    test('LING-039: Yes/No question transforms with ob and verb-final in Konjunktiv', () {
      final res = GermanIndirectQuestionsImperativesEngine.transformQuestion(
        introMatrix: 'Der Reisende fragte',
        directQuestion: 'Kommt der Zug pünktlich an?',
        isYesNo: true,
        subject: 'der Zug',
        verbInKonjunktiv: 'ankomme',
        remainder: 'pünktlich',
      );

      expect(res.actType, equals(ReportedSpeechActType.yesNoQuestionOb));
      expect(res.introductoryConnector, equals('ob'));
      expect(res.fullIndirectSentence, equals('Der Reisende fragte, ob der Zug pünktlich ankomme.'));
    });

    test('LING-039: W-Question retains interrogative adverb and delays verb', () {
      final res = GermanIndirectQuestionsImperativesEngine.transformQuestion(
        introMatrix: 'Sie wollte wissen',
        directQuestion: 'Wann beginnt die Sitzung?',
        isYesNo: false,
        whWord: 'wann',
        subject: 'die Sitzung',
        verbInKonjunktiv: 'beginne',
      );

      expect(res.actType, equals(ReportedSpeechActType.whQuestion));
      expect(res.introductoryConnector, equals('wann'));
      expect(res.fullIndirectSentence, equals('Sie wollte wissen, wann die Sitzung beginne.'));
    });

    test('LING-039: Direct imperative command transforms using sollen', () {
      final res = GermanIndirectQuestionsImperativesEngine.transformImperative(
        introMatrix: 'Der Abteilungsleiter verlangte',
        reportedSubject: 'die Mitarbeiter',
        actionInfinitive: 'pünktlich erscheinen',
        isPlural: true,
      );

      expect(res.actType, equals(ReportedSpeechActType.imperativeCommand));
      expect(res.fullIndirectSentence, equals('Der Abteilungsleiter verlangte, die Mitarbeiter pünktlich erscheinen sollten.'));
    });

    test('UI Bridge generates accurate Task 4916 diagnostics report', () {
      final bridge = Vol116Wave16UIBridge();
      final report = bridge.getTask4916Diagnostics();

      expect(report['task_id'], equals(4916));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(84));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
