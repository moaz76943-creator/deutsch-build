import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_ersatzinfinitiv_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave15_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4915 Ersatzinfinitiv Engine Tests', () {
    test('LING-038: Modal verb in main clause constructs double infinitive at end', () {
      final res = GermanErsatzinfinitivEngine.buildSentence(
        subject: 'Ich',
        auxiliary: 'habe',
        governingVerb: 'können',
        governedInfinitive: 'lesen',
        objectOrComplement: 'das Buch',
        clauseType: DoubleInfinitiveClauseType.mainClause,
      );

      expect(res.verbType, equals(ReplacementVerbType.modalVerb));
      expect(res.fullSentence, equals('Ich habe das Buch lesen können.'));
    });

    test('LING-038: Causative lassen constructs double infinitive correctly', () {
      final res = GermanErsatzinfinitivEngine.buildSentence(
        subject: 'Er',
        auxiliary: 'hat',
        governingVerb: 'lassen',
        governedInfinitive: 'reparieren',
        objectOrComplement: 'sein Auto',
        clauseType: DoubleInfinitiveClauseType.mainClause,
      );

      expect(res.verbType, equals(ReplacementVerbType.causativeLassen));
      expect(res.fullSentence, equals('Er hat sein Auto reparieren lassen.'));
    });

    test('LING-038: Subordinate clause triggers Oberfeldumstellung word order', () {
      final res = GermanErsatzinfinitivEngine.buildSentence(
        subject: 'er',
        auxiliary: 'hat',
        governingVerb: 'müssen',
        governedInfinitive: 'lösen',
        objectOrComplement: 'die Aufgabe',
        clauseType: DoubleInfinitiveClauseType.subordinateClauseOberfeld,
        subordinateConjunction: 'weil',
      );

      // In Oberfeldumstellung: "weil er die Aufgabe hat lösen müssen."
      expect(res.fullSentence, equals('weil er die Aufgabe hat lösen müssen.'));
      expect(res.clauseType, equals(DoubleInfinitiveClauseType.subordinateClauseOberfeld));
    });

    test('UI Bridge generates accurate Task 4915 diagnostics report', () {
      final bridge = Vol116Wave15UIBridge();
      final report = bridge.getTask4915Diagnostics();

      expect(report['task_id'], equals(4915));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(85));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
