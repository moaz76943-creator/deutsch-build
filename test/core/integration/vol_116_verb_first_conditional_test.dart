import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_verb_first_conditional_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave34_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4934 Verb-First Conditional Engine Tests', () {
    test('LING-057: V1 conditional constructs Hätte ich Zeit without wenn', () {
      final res = GermanVerbFirstConditionalEngine.convertWennToVerbFirst(
        subject: 'ich',
        finiteVerbK2: 'hätte',
        conditionRemainder: 'mehr Zeit gehabt',
        consequenceMainVerb: 'wäre',
        consequenceSubject: 'ich',
        consequenceRemainder: 'gekommen',
        useCorrelateSo: true,
      );

      expect(res.conditionVerbFirst, equals('Hätte ich mehr Zeit gehabt'));
      expect(res.fullV1Sentence, equals('Hätte ich mehr Zeit gehabt, so wäre ich gekommen.'));
      expect(res.conditionWennClause, equals('Wenn ich mehr Zeit gehabt hätte'));
      expect(res.arabicNuanceExplanation, contains('V1-Stellung'));
    });

    test('LING-057: Future potential conditional with sollte constructs V1 cleanly', () {
      final res = GermanVerbFirstConditionalEngine.convertWennToVerbFirst(
        subject: 'es',
        finiteVerbK2: 'sollte',
        conditionRemainder: 'morgen regnen',
        consequenceMainVerb: 'sagen',
        consequenceSubject: 'wir',
        consequenceRemainder: 'das Treffen ab',
        useCorrelateSo: false,
      );

      expect(res.conditionVerbFirst, equals('Sollte es morgen regnen'));
      expect(res.fullV1Sentence, equals('Sollte es morgen regnen, sagen wir das Treffen ab.'));
    });

    test('UI Bridge generates accurate Task 4934 diagnostics report', () {
      final bridge = Vol116Wave34UIBridge();
      final report = bridge.getTask4934Diagnostics();

      expect(report['task_id'], equals(4934));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(66));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
