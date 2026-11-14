import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_prepositional_correlate_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave13_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4913 Prepositional Correlate Engine Tests', () {
    test('LING-036: abhängen von constructs mandatory davon correlate with ob-clause', () {
      final res = GermanPrepositionalCorrelateEngine.buildComplexClause(
        subject: 'Es',
        conjugatedVerb: 'hängt',
        verbWithPrepositionKey: 'abhängen von',
        subType: CorrelateSubordinateType.obClause,
        subClauseContent: 'wir rechtzeitig ankommen',
      );

      expect(res.correlatePlaceholder, equals('davon'));
      expect(res.obligation, equals(CorrelateObligationStatus.mandatory));
      expect(res.fullSentence, equals('Es hängt davon, ob wir rechtzeitig ankommen.'));
    });

    test('LING-036: sich freuen auf constructs darauf correlate with dass-clause', () {
      final res = GermanPrepositionalCorrelateEngine.buildComplexClause(
        subject: 'Ich',
        conjugatedVerb: 'freue mich',
        verbWithPrepositionKey: 'sich freuen auf',
        subType: CorrelateSubordinateType.dassClause,
        subClauseContent: 'du mich besuchst',
      );

      expect(res.correlatePlaceholder, equals('darauf'));
      expect(res.fullSentence, equals('Ich freue mich darauf, dass du mich besuchst.'));
    });

    test('LING-036: Infinitive clause with correlate links seamlessly', () {
      final res = GermanPrepositionalCorrelateEngine.buildComplexClause(
        subject: 'Er',
        conjugatedVerb: 'rechnet',
        verbWithPrepositionKey: 'rechnen mit',
        subType: CorrelateSubordinateType.infinitiveZu,
        subClauseContent: 'die Prüfung zu bestehen',
      );

      expect(res.correlatePlaceholder, equals('damit'));
      expect(res.fullSentence, equals('Er rechnet damit, die Prüfung zu bestehen.'));
    });

    test('UI Bridge generates accurate Task 4913 diagnostics report', () {
      final bridge = Vol116Wave13UIBridge();
      final report = bridge.getTask4913Diagnostics();

      expect(report['task_id'], equals(4913));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(87));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
