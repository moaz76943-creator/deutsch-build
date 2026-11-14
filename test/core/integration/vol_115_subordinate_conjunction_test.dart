import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_subordinate_conjunction_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave11_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4897 Subordinate Conjunction Engine Tests', () {
    test('LING-020: Main clause first constructs regular S-V order with verb-final subclause', () {
      final res = GermanSubordinateConjunctionEngine.buildSentence(
        conjunction: 'weil',
        mainSubject: 'Ich',
        mainVerb: 'bleibe',
        mainRemainder: 'zu Hause',
        subSubject: 'es',
        subVerb: 'regnet',
        subRemainder: 'stark',
        position: ClausePosition.mainFirst,
      );

      expect(res.category, equals(ConjunctionCategory.kausal));
      expect(res.generatedComplexSentence, equals('Ich bleibe zu Hause, weil es stark regnet.'));
    });

    test('LING-020: Subordinate clause first enforces main clause inversion (Verb-Subject)', () {
      final res = GermanSubordinateConjunctionEngine.buildSentence(
        conjunction: 'obwohl',
        mainSubject: 'Er',
        mainVerb: 'arbeitet',
        mainRemainder: 'weiter',
        subSubject: 'er',
        subVerb: 'ist',
        subRemainder: 'sehr müde',
        position: ClausePosition.subordinateFirst,
      );

      expect(res.category, equals(ConjunctionCategory.konzessiv));
      // Inversion: "arbeitet er weiter."
      expect(res.generatedComplexSentence, equals('Obwohl er sehr müde ist, arbeitet er weiter.'));
    });

    test('LING-020: Conditional clause with wenn triggers correct word order', () {
      final res = GermanSubordinateConjunctionEngine.buildSentence(
        conjunction: 'wenn',
        mainSubject: 'Wir',
        mainVerb: 'gehen',
        mainRemainder: 'in den Park',
        subSubject: 'die Sonne',
        subVerb: 'scheint',
        subRemainder: '',
        position: ClausePosition.subordinateFirst,
      );

      expect(res.category, equals(ConjunctionCategory.konditional));
      expect(res.generatedComplexSentence, equals('Wenn die Sonne scheint, gehen wir in den Park.'));
    });

    test('UI Bridge generates accurate Task 4897 diagnostics report', () {
      final bridge = Vol115Wave11UIBridge();
      final report = bridge.getTask4897Diagnostics();

      expect(report['task_id'], equals(4897));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
      expect(report['word_order_enforced'], equals('VERBLETZTSTELLUNG_AND_VORFELD_INVERSION'));
    });
  });
}
